#!/bin/bash

# Usage: ./delete-companies.sh -i input.csv

# See ConnectWise documentation on authorization: 
# https://developer.connectwise.com/Products/ConnectWise_PSA/REST#/Documents/getSystemDocuments
# Base URL syntax: 
# https://developer.connectwise.com/Best_Practices/PSA_Cloud_URL_Formatting
# Get clientId: 
# https://developer.connectwise.com/ClientID


# Variables
input_file=""
log_success=""
log_failure=""

# Set your Authorization token, Client ID here
auth_token="YOUR_BASE64_ENCODED_TOKEN_HERE"
client_id="YOUR_CLIENT_ID_HERE"

# Set your Base URL here. Defaults to api-na.
base_url="https://api-na.myconnectwise.net/v2024_1/apis/3.0/"

# Parse the input flag for CSV file
while getopts "i:" flag; do
  case "${flag}" in
    i) input_file=${OPTARG} ;;
    *) echo "Invalid option. Use -i for input file." ;;
  esac
done

# Check for input file
if [ -z "$input_file" ]; then
  echo "Error: Input CSV file is required. Usage: ./delete-companies.sh -i input.csv"
  exit 1
fi

# Extract the base name of the input file without the extension
input_basename=$(basename "$input_file" .csv)

# Set log file names with the input filename appended
log_success="success_log_${input_basename}.txt"
log_failure="failure_log_${input_basename}.txt"

# Dry run - show the first few companies and count
echo "===== Dry Run Preview ====="
total_count=$(tail -n +2 "$input_file" | grep -v '^$' | wc -l) # Skip header and count non-empty lines
head -n 5 "$input_file"
echo
echo "==========================="
echo "Total companies to delete: $total_count"
echo "==========================="

# Ask for confirmation
read -p "Do you want to proceed with deletion? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  echo "Deletion canceled."
  exit 0
fi

# Function to log success and failure with simplified timestamp
log_success() {
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp: Deleted company $1 (RecID: $2)" | tee -a "$log_success"
}

log_failure() {
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp: Failed to delete company $1 (RecID: $2)" | tee -a "$log_failure"
}

# Loop through each row and perform the deletion
tail -n +2 "$input_file" | tr -d '\r' | while IFS=',' read -r rec_id company_name || [ -n "$rec_id" ]; do
  # Skip empty rows
  if [ -z "$rec_id" ] || [ -z "$company_name" ]; then
    continue
  fi

  echo "Attempting to delete: $company_name (RecID: $rec_id)"

  # API request to delete the company
  response=$(curl --location --request DELETE "${base_url}company/companies/$rec_id" \
    --header "Authorization: Basic $auth_token" \
    --header "clientId: $client_id" --silent --write-out "HTTPSTATUS:%{http_code}" --output /dev/null)

  # Extract the HTTP status code from the response
  http_status=$(echo "$response" | sed -e 's/.*HTTPSTATUS://')

  # Log success for 200 or 204 status codes, otherwise log failure
  if [[ "$http_status" -eq 200 || "$http_status" -eq 204 ]]; then
    log_success "$company_name" "$rec_id"
  else
    log_failure "$company_name" "$rec_id"
  fi

  # Wait for 500ms before next request
  sleep 0.5

done

echo "Deletion process completed."
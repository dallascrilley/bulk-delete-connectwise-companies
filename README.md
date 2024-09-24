# Author
Dallas Crilley

# Delete Companies Script

This script is designed to delete companies from ConnectWise using the ConnectWise REST API. It reads a CSV file containing company IDs and names, and attempts to delete each company via API calls.

### ConnectWise API Documentation

- [Authorization and Client ID](https://developer.connectwise.com/Products/ConnectWise_PSA/REST#/Documents/getSystemDocuments)
- [PSA Cloud URL (Base URL) Formatting](https://developer.connectwise.com/Best_Practices/PSA_Cloud_URL_Formatting)
- [REST API and Endpoints](https://developer.connectwise.com/Products/ConnectWise_PSA/REST)

## Usage

```bash
./delete-companies.sh -i input.csv
```

### Required Arguments:
- `-i` : Specifies the input CSV file containing company data (with a header row).

### CSV File Format
The input CSV file must have the following format:

```
RecID,Company Name
1,Company One
2,Company Two
...
```

## Script Details

### Variables

- `input_file`: Path to the CSV file.
- `log_success`: Log file to store successful deletions.
- `log_failure`: Log file to store failed deletions.
- `auth_token`: Your ConnectWise Authorization token, base64 encoded.
- `client_id`: Your ConnectWise Client ID.
- `base_url`: The base URL for the ConnectWise API.

### Dry Run

Before executing the deletion, the script performs a dry run that previews the first few companies and shows the total count:

```
===== Dry Run Preview =====
<Preview of companies>
===========================
Total companies to delete: X
===========================
```

After the preview, you will be prompted to confirm the deletion process.

### API Interaction

For each company in the input CSV file, the script makes a `DELETE` request to the ConnectWise API:

```
DELETE {base_url}company/companies/{rec_id}
```

- If the deletion is successful (HTTP status 200 or 204), the company will be logged in the success log.
- If the deletion fails, the company will be logged in the failure log.

### Logs

- Success log: `success_log_<input_file_basename>.txt`
- Failure log: `failure_log_<input_file_basename>.txt`

### Notes

- Make sure to replace `auth_token` and `client_id` with your actual credentials before running the script.
- The script includes a delay of 500ms between API requests to avoid overloading the API.

## License

This script is released under the MIT License.

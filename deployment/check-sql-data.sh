#!/usr/bin/env bash

# Verifies that the deployment VM can read the application SQL data.
# Authentication uses the deployment VM's system-assigned managed identity.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: ./deployment/check-sql-data.sh <sql-server-name> <database-name>"
  exit 1
fi

SQL_SERVER_NAME="$1"
SQL_DATABASE_NAME="$2"
SQL_SERVER_FQDN="${SQL_SERVER_NAME}.database.windows.net"

if ! command -v sqlcmd > /dev/null 2>&1; then
  echo "Error: sqlcmd is not installed. Run prepare-deployment-vm.sh first."
  exit 1
fi

echo "Checking Messages data in '${SQL_DATABASE_NAME}'..."

sqlcmd \
  -S "${SQL_SERVER_FQDN}" \
  -d "${SQL_DATABASE_NAME}" \
  --authentication-method ActiveDirectoryManagedIdentity \
  -Q "SELECT Id, Message FROM dbo.Messages ORDER BY Id;" \
  -b

echo "SQL data check completed successfully."

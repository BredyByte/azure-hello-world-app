#!/usr/bin/env bash

# Creates and updates Azure SQL application data and permissions.
# Authentication uses the deployment VM's system-assigned managed identity.

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: ./deployment/deploy-sql-data.sh <sql-server-name> <database-name> <web-app-name>"
  exit 1
fi

SQL_SERVER_NAME="$1"
SQL_DATABASE_NAME="$2"
WEB_APP_NAME="$3"
SQL_SERVER_FQDN="${SQL_SERVER_NAME}.database.windows.net"

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIRECTORY}/.." && pwd)"
SQL_MIGRATION_FILE="${REPOSITORY_ROOT}/sql/001-create-messages.sql"

if ! command -v sqlcmd > /dev/null 2>&1; then
  echo "Error: sqlcmd is not installed. Run prepare-deployment-vm.sh first."
  exit 1
fi

if [[ ! -f "${SQL_MIGRATION_FILE}" ]]; then
  echo "Error: SQL migration file does not exist: ${SQL_MIGRATION_FILE}"
  exit 1
fi

echo "Deploying SQL data and permissions to '${SQL_DATABASE_NAME}'..."

sqlcmd \
  -S "${SQL_SERVER_FQDN}" \
  -d "${SQL_DATABASE_NAME}" \
  --authentication-method ActiveDirectoryManagedIdentity \
  -v WEB_APP_NAME="${WEB_APP_NAME}"  \
  -i "${SQL_MIGRATION_FILE}" \
  -b

echo "SQL deployment completed successfully."

#!/usr/bin/env bash

# Uploads static application content to private Azure Blob containers.
# Uses the deployment VM's managed identity, never a Storage access key.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./deployment/deploy-storage-content.sh <storage-account-name>"
  exit 1
fi

STORAGE_ACCOUNT_NAME="$1"

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIRECTORY}/.." && pwd)"
CONTENT_DIRECTORY="${REPOSITORY_ROOT}/content"

if ! command -v az > /dev/null 2>&1; then
  echo "Error: Azure CLI is not installed. Run prepare-deployment-vm.sh first."
  exit 1
fi

az login --identity --allow-no-subscriptions --only-show-errors > /dev/null

for CONTAINER_NAME in images data text; do
  SOURCE_DIRECTORY="${CONTENT_DIRECTORY}/${CONTAINER_NAME}"

  if [[ ! -d "${SOURCE_DIRECTORY}" ]]; then
    echo "Error: missing directory: ${SOURCE_DIRECTORY}"
    exit 1
  fi

  echo "Uploading files to the '${CONTAINER_NAME}' container..."

  az storage blob upload-batch \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --destination "${CONTAINER_NAME}" \
    --source "${SOURCE_DIRECTORY}" \
    --auth-mode login \
    --overwrite true \
    --output table
done

echo "Storage content deployment completed successfully."

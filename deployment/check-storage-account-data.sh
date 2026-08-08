#!/usr/bin/env bash

# Checks that the required application content exists in Azure Blob Storage.
# Uses the deployment VM managed identity.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./deployment/storage-account-data-check.sh <storage-account-name>"
  exit 1
fi

STORAGE_ACCOUNT_NAME="$1"
FAILED_CHECKS=0

if ! command -v az > /dev/null 2>&1; then
  echo "Error: Azure CLI is not installed. Run prepare-deployment-vm.sh first."
  exit 1
fi

az login --identity --allow-no-subscriptions --only-show-errors > /dev/null

check_blob() {
  local CONTAINER_NAME="$1"
  local BLOB_NAME="$2"

  local EXISTS
  EXISTS="$(
    az storage blob exists \
      --account-name "${STORAGE_ACCOUNT_NAME}" \
      --container-name "${CONTAINER_NAME}" \
      --name "${BLOB_NAME}" \
      --auth-mode login \
      --query "exists" \
      --output tsv
  )"

  if [[ "${EXISTS}" == "true" ]]; then
    echo "✓ ${CONTAINER_NAME}/${BLOB_NAME}"
  else
    echo "✗ Missing: ${CONTAINER_NAME}/${BLOB_NAME}"
    FAILED_CHECKS=1
  fi
}

echo "Checking required application content..."

check_blob "text" "welcome.txt"
check_blob "data" "app-info.json"
check_blob "images" "azure-logo.png"
check_blob "images" "terraform-logo.png"

echo
echo "All blobs currently stored:"

for CONTAINER_NAME in images data text; do
  echo
  echo "===== ${CONTAINER_NAME} ====="

  az storage blob list \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --container-name "${CONTAINER_NAME}" \
    --auth-mode login \
    --query "[].name" \
    --output table
done

if [[ "${FAILED_CHECKS}" -ne 0 ]]; then
  echo
  echo "Storage validation failed."
  exit 1
fi

echo
echo "Storage validation completed successfully."

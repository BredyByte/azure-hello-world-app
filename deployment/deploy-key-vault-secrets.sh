#!/usr/bin/env bash

# Uploads non-sensitive demo secrets to Azure Key Vault.
# Real passwords, tokens, and private keys must never be committed to Git.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./deployment/deploy-key-vault-secrets.sh <key-vault-name>"
  exit 1
fi

KEY_VAULT_NAME="$1"
SECRET_NAME="welcome-message"

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIRECTORY}/.." && pwd)"
SECRET_FILE="${REPOSITORY_ROOT}/content/key-vault/welcome-message.txt"

if ! command -v az > /dev/null 2>&1; then
  echo "Error: Azure CLI is not installed. Run prepare-deployment-vm.sh first."
  exit 1
fi

if [[ ! -f "${SECRET_FILE}" ]]; then
  echo "Error: secret source file does not exist: ${SECRET_FILE}"
  exit 1
fi

az login --identity --allow-no-subscriptions --only-show-errors > /dev/null

echo "Deploying '${SECRET_NAME}' to Key Vault '${KEY_VAULT_NAME}'..."

SECRET_ID="$(
  az keyvault secret set \
    --vault-name "${KEY_VAULT_NAME}" \
    --name "${SECRET_NAME}" \
    --file "${SECRET_FILE}" \
    --encoding utf-8 \
    --content-type "text/plain" \
    --query "id" \
    --output tsv
)"

echo "Key Vault secret deployed successfully."
echo "Secret URI: ${SECRET_ID}"

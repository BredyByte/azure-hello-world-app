#!/usr/bin/env bash

# Displays the Key Vault inventory without exposing secret values.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./deployment/key-vault-data-check.sh <key-vault-name>"
  exit 1
fi

KEY_VAULT_NAME="$1"

az login --identity --allow-no-subscriptions --only-show-errors > /dev/null

echo "===== Key Vault secrets ====="

az keyvault secret list \
  --vault-name "${KEY_VAULT_NAME}" \
  --query "[].{Id:id,Enabled:attributes.enabled,Expires:attributes.expires,ContentType:contentType}" \
  --output table

echo
echo "===== Key Vault certificates ====="

az keyvault certificate list \
  --vault-name "${KEY_VAULT_NAME}" \
  --query "[].{Id:id,Enabled:attributes.enabled,Expires:attributes.expires}" \
  --output table

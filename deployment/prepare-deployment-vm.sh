#!/usr/bin/env bash

# Prepares a new private deployment VM with the basic deployment tools.
# Safe to run multiple times.

set -euo pipefail

echo "Updating Ubuntu package information..."
sudo apt-get update

echo "Installing base deployment tools..."
sudo apt-get install -y \
  ca-certificates \
  curl \
  dnsutils \
  git \
  jq \
  make \
  openssl \
  unzip \
  zip

if command -v az > /dev/null 2>&1; then
  echo "Azure CLI is already installed:"
  az version --output table
else
  echo "Installing Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

  echo "Azure CLI installed:"
  az version --output table
fi

echo
echo "Deployment VM preparation completed successfully."

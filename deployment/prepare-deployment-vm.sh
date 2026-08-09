#!/usr/bin/env bash

# Prepares a new private deployment VM with the basic deployment tools.
# Safe to run multiple times.

set -euo pipefail

echo "Updating Ubuntu package information..."
sudo apt-get update

echo "Installing base deployment tools..."
sudo apt-get install -y \
  bzip2 \
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

if command -v sqlcmd > /dev/null 2>&1; then
  echo "sqlcmd is already installed:"
  sqlcmd --version
else
  echo "Installing sqlcmd (Go)..."

  SQLCMD_TEMP_DIRECTORY="$(mktemp -d)"
  SQLCMD_ARCHIVE="${SQLCMD_TEMP_DIRECTORY}/sqlcmd-linux-amd64.tar.bz2"
  SQLCMD_BINARY="${SQLCMD_TEMP_DIRECTORY}/sqlcmd"

  echo "Downloading the sqlcmd archive..."
  curl -fsSL \
    -o "${SQLCMD_ARCHIVE}" \
    https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-linux-amd64.tar.bz2

  echo "Checking the downloaded archive..."
  tar -tjf "${SQLCMD_ARCHIVE}" > /dev/null

  echo "Extracting sqlcmd..."
  tar -xjf "${SQLCMD_ARCHIVE}" \
    -C "${SQLCMD_TEMP_DIRECTORY}"

  if [[ ! -f "${SQLCMD_BINARY}" ]]; then
    echo "Error: sqlcmd binary was not found after extraction."
    exit 1
  fi

  echo "Installing sqlcmd in /usr/local/bin..."
  sudo install -m 0755 \
    "${SQLCMD_BINARY}" \
    /usr/local/bin/sqlcmd

  rm -rf "${SQLCMD_TEMP_DIRECTORY}"

  echo "sqlcmd installed:"
  sqlcmd --version
fi

echo
echo "Deployment VM preparation completed successfully."

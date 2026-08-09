#!/usr/bin/env bash

# Packages and deploys the Flask application from the private deployment VM.
# Authentication uses the deployment VM's system-assigned managed identity.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: ./deployment/deploy-web-app.sh <resource-group-name> <web-app-name>"
  exit 1
fi

RESOURCE_GROUP_NAME="$1"
WEB_APP_NAME="$2"
WEB_APP_URL="https://${WEB_APP_NAME}.azurewebsites.net"

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIRECTORY}/.." && pwd)"
RELEASE_DIRECTORY="$(mktemp -d)"
RELEASE_ARCHIVE="${RELEASE_DIRECTORY}/web-app.zip"

cleanup() {
  rm -rf "${RELEASE_DIRECTORY}"
}

trap cleanup EXIT

for command in az curl zip; do
  if ! command -v "${command}" > /dev/null 2>&1; then
    echo "Error: '${command}' is not installed. Run prepare-deployment-vm.sh first."
    exit 1
  fi
done

echo "Signing in with the deployment VM managed identity..."
az login --identity --allow-no-subscriptions > /dev/null

echo "Creating application release archive..."
(
  cd "${REPOSITORY_ROOT}/app"

  zip -qr "${RELEASE_ARCHIVE}" .
)

echo "Deploying the release to '${WEB_APP_NAME}'..."
az webapp deploy \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --name "${WEB_APP_NAME}" \
  --src-path "${RELEASE_ARCHIVE}" \
  --type zip \
  --clean true \
  --restart true \
  --track-status true \
  --output table

echo "Checking application routes through the private App Service endpoint..."
for route in / /key /storage /sql; do
  for attempt in {1..12}; do
    if curl --fail --silent --show-error --max-time 30 "${WEB_APP_URL}${route}" > /dev/null; then
      echo "Route '${route}' is healthy."
      break
    fi

    if [[ "${attempt}" -eq 12 ]]; then
      echo "Error: route '${route}' did not become healthy after deployment."
      exit 1
    fi

    echo "Route '${route}' is not ready yet; retrying in 10 seconds..."
    sleep 10
  done
done

echo "Web App deployment completed successfully."

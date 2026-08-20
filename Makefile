SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help
.NOTPARALLEL:

DEPLOYMENT_DIR = deployment

# Default Azure resource names. Any value can still be overridden from the
# command line, for example: make check-sql SQL_DATABASE_NAME=another-database
RESOURCE_GROUP_NAME = rg-dev-helloworldf800
KEY_VAULT_NAME = kv-dev-helloworldf800
SQL_SERVER_NAME = sql-dev-helloworldf800
SQL_DATABASE_NAME = sqldb-dev-helloworldf800
STORAGE_ACCOUNT_NAME = stdevhelloworldf800
WEB_APP_NAME = app-dev-helloworldf800

.PHONY: help prepare deploy deploy-key-vault deploy-storage deploy-sql deploy-web-app \
	check check-key-vault check-storage check-sql require-resource-group \
	require-key-vault require-storage require-sql require-web-app

help:
	@echo "Available commands:"
	@echo "  make prepare           Prepare the deployment VM"
	@echo "  make deploy            Prepare VM and deploy all components"
	@echo "  make check             Run all data checks"
	@echo "  make deploy-key-vault  Deploy Key Vault secrets"
	@echo "  make deploy-storage    Deploy Storage Account content"
	@echo "  make deploy-sql        Deploy SQL schema, data, and permissions"
	@echo "  make deploy-web-app    Package and deploy the web application"
	@echo "  make check-key-vault   Check Key Vault data"
	@echo "  make check-storage     Check Storage Account data"
	@echo "  make check-sql         Check SQL data"
	@echo
	@echo "Default deployment:"
	@echo "  make deploy"
	@echo
	@echo "Default checks:"
	@echo "  make check"

prepare:
	./$(DEPLOYMENT_DIR)/prepare-deployment-vm.sh

deploy: prepare deploy-key-vault deploy-storage deploy-sql deploy-web-app
	@echo "All deployment steps completed successfully."

deploy-key-vault: require-key-vault
	./$(DEPLOYMENT_DIR)/deploy-key-vault-secrets.sh "$(KEY_VAULT_NAME)"

deploy-storage: require-storage
	./$(DEPLOYMENT_DIR)/deploy-storage-content.sh "$(STORAGE_ACCOUNT_NAME)"

deploy-sql: require-sql require-web-app
	./$(DEPLOYMENT_DIR)/deploy-sql-data.sh \
		"$(SQL_SERVER_NAME)" \
		"$(SQL_DATABASE_NAME)" \
		"$(WEB_APP_NAME)"

deploy-web-app: require-resource-group require-web-app
	./$(DEPLOYMENT_DIR)/deploy-web-app.sh \
		"$(RESOURCE_GROUP_NAME)" \
		"$(WEB_APP_NAME)"

check: check-key-vault check-storage check-sql
	@echo "All checks completed successfully."

check-key-vault: require-key-vault
	./$(DEPLOYMENT_DIR)/check-key-vault-data.sh "$(KEY_VAULT_NAME)"

check-storage: require-storage
	./$(DEPLOYMENT_DIR)/check-storage-account-data.sh "$(STORAGE_ACCOUNT_NAME)"

check-sql: require-sql
	./$(DEPLOYMENT_DIR)/check-sql-data.sh \
		"$(SQL_SERVER_NAME)" \
		"$(SQL_DATABASE_NAME)"

require-resource-group:
	@test -n "$(RESOURCE_GROUP_NAME)" || { echo "Error: RESOURCE_GROUP_NAME is required."; exit 1; }

require-key-vault:
	@test -n "$(KEY_VAULT_NAME)" || { echo "Error: KEY_VAULT_NAME is required."; exit 1; }

require-storage:
	@test -n "$(STORAGE_ACCOUNT_NAME)" || { echo "Error: STORAGE_ACCOUNT_NAME is required."; exit 1; }

require-sql:
	@test -n "$(SQL_SERVER_NAME)" || { echo "Error: SQL_SERVER_NAME is required."; exit 1; }
	@test -n "$(SQL_DATABASE_NAME)" || { echo "Error: SQL_DATABASE_NAME is required."; exit 1; }

require-web-app:
	@test -n "$(WEB_APP_NAME)" || { echo "Error: WEB_APP_NAME is required."; exit 1; }

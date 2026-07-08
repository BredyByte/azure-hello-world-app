import os

from dotenv import load_dotenv

from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient

load_dotenv()

TENANT_ID = os.getenv("AZURE_TENANT_ID")
CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")

KEY_VAULT_URL = os.getenv("KEY_VAULT_URL")

credential = ClientSecretCredential(
    tenant_id=TENANT_ID,
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET
)

client = SecretClient(
    vault_url=KEY_VAULT_URL,
    credential=credential
)


def get_secret(secret_name: str) -> str:
    """
    Returns a secret stored inside Azure Key Vault.
    """

    secret = client.get_secret(secret_name)

    return secret.value

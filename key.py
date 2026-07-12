import os

from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

load_dotenv()

KEY_VAULT_URL = os.getenv("KEY_VAULT_URL")

credential = DefaultAzureCredential()

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

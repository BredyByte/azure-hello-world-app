import json
import os
from datetime import datetime, timedelta, timezone

from dotenv import load_dotenv

from azure.identity import DefaultAzureCredential
from azure.storage.blob import (
    BlobServiceClient,
    BlobSasPermissions,
    generate_blob_sas,
)

load_dotenv()

STORAGE_ACCOUNT_NAME = os.getenv("AZURE_STORAGE_ACCOUNT_NAME")

credential = DefaultAzureCredential()

blob_service_client = BlobServiceClient(
    account_url=(
        f"https://{STORAGE_ACCOUNT_NAME}.blob.core.windows.net"
    ),
    credential=credential,
)


def read_text_blob(container_name: str, blob_name: str) -> str:
    blob_client = blob_service_client.get_blob_client(
        container=container_name,
        blob=blob_name,
    )

    content = blob_client.download_blob().readall()

    return content.decode("utf-8")


def read_json_blob(container_name: str, blob_name: str) -> dict:
    content = read_text_blob(container_name, blob_name)

    return json.loads(content)


def list_images(container_name: str) -> list:
    container_client = blob_service_client.get_container_client(
        container_name
    )

    images = []

    for blob in container_client.list_blobs():
        images.append(
            {
                "name": blob.name,
                "url": get_blob_sas_url(
                    container_name,
                    blob.name,
                ),
            }
        )

    return images


def get_blob_sas_url(container_name: str, blob_name: str) -> str:
    blob_client = blob_service_client.get_blob_client(
        container=container_name,
        blob=blob_name,
    )

    now = datetime.now(timezone.utc)
    expiry = now + timedelta(hours=1)

    user_delegation_key = blob_service_client.get_user_delegation_key(
        key_start_time=now - timedelta(minutes=5),
        key_expiry_time=expiry,
    )

    sas_token = generate_blob_sas(
        account_name=blob_client.account_name,
        container_name=container_name,
        blob_name=blob_name,
        user_delegation_key=user_delegation_key,
        permission=BlobSasPermissions(read=True),
        expiry=expiry,
    )

    return f"{blob_client.url}?{sas_token}"

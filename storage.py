import json
import os

from dotenv import load_dotenv
from datetime import datetime, timedelta
from azure.storage.blob import (

    BlobServiceClient,

    generate_blob_sas,

    BlobSasPermissions,

)

load_dotenv()

connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")

blob_service_client = BlobServiceClient.from_connection_string(
    connection_string
)


def read_text_blob(container_name: str, blob_name: str) -> str:
    """
    Reads a text blob and returns it as a string.
    """

    blob_client = blob_service_client.get_blob_client(
        container=container_name,
        blob=blob_name,
    )

    content = blob_client.download_blob().readall()

    return content.decode("utf-8")


def read_json_blob(container_name: str, blob_name: str) -> dict:
    """
    Reads a JSON blob and returns a Python dictionary.
    """

    content = read_text_blob(container_name, blob_name)

    return json.loads(content)


def list_images(container_name: str) -> list:
    """
    Returns all images inside a container together with
    their temporary SAS URLs.
    """

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
                    blob.name
                )
            }
        )

    return images


def get_blob_url(container_name: str, blob_name: str) -> str:
    """
    Returns the URL of a blob.
    """

    blob_client = blob_service_client.get_blob_client(
        container=container_name,
        blob=blob_name,
    )

    return blob_client.url


def get_blob_sas_url(container_name: str, blob_name: str) -> str:
    """
    Generate a temporary URL that allows the browser
    to download a private blob.
    """

    blob_client = blob_service_client.get_blob_client(
        container=container_name,
        blob=blob_name,
    )

    sas_token = generate_blob_sas(
        account_name=blob_client.account_name,
        container_name=container_name,
        blob_name=blob_name,
        account_key=blob_service_client.credential.account_key,
        permission=BlobSasPermissions(read=True),
        expiry=datetime.utcnow() + timedelta(hours=1),
    )

    return f"{blob_client.url}?{sas_token}"

import json
import os

from dotenv import load_dotenv
from azure.storage.blob import BlobServiceClient

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


def list_blobs(container_name: str) -> list:
    """
    Returns a list of blob names inside a container.
    """

    container_client = blob_service_client.get_container_client(
        container_name
    )

    return [
        blob.name
        for blob in container_client.list_blobs()
    ]


def get_blob_url(container_name: str, blob_name: str) -> str:
    """
    Returns the URL of a blob.
    """

    blob_client = blob_service_client.get_blob_client(
        container=container_name,
        blob=blob_name,
    )

    return blob_client.url

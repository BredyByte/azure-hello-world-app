import os
import struct
import urllib.parse

from dotenv import load_dotenv

from azure.identity import DefaultAzureCredential
from sqlalchemy import create_engine, text

load_dotenv()

SQL_SERVER = os.getenv("SQL_SERVER")
SQL_DATABASE = os.getenv("SQL_DATABASE")

credential = DefaultAzureCredential()

SQL_COPT_SS_ACCESS_TOKEN = 1256


def get_engine():
    access_token = credential.get_token(
        "https://database.windows.net/.default"
    ).token

    token_bytes = access_token.encode("utf-16-le")

    token_struct = struct.pack(
        f"<I{len(token_bytes)}s",
        len(token_bytes),
        token_bytes,
    )

    odbc_connection_string = (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server=tcp:{SQL_SERVER},1433;"
        f"Database={SQL_DATABASE};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=30;"
    )

    params = urllib.parse.quote_plus(odbc_connection_string)

    return create_engine(
        f"mssql+pyodbc:///?odbc_connect={params}",
        connect_args={
            "attrs_before": {
                SQL_COPT_SS_ACCESS_TOKEN: token_struct
            }
        },
    )


def get_messages():
    engine = get_engine()

    with engine.connect() as connection:
        result = connection.execute(
            text(
                """
                SELECT
                    Id,
                    Message
                FROM Messages
                ORDER BY Id
                """
            )
        )

        return result.fetchall()

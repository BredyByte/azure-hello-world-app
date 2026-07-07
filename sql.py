import os

from dotenv import load_dotenv

from sqlalchemy import create_engine, text

load_dotenv()

server = os.getenv("SQL_SERVER")
database = os.getenv("SQL_DATABASE")
username = os.getenv("SQL_USERNAME")
password = os.getenv("SQL_PASSWORD")

connection_string = (
    f"mssql+pyodbc://{username}:{password}"
    f"@{server}/{database}"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&Encrypt=yes"
    "&TrustServerCertificate=no"
)

engine = create_engine(connection_string)


def get_messages():

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

        messages = result.fetchall()

    return messages

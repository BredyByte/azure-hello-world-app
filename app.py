from flask import Flask, render_template

from storage import (
    read_text_blob,
    read_json_blob,
    list_images,
)

from sql import get_messages

app = Flask(__name__)


@app.route("/")
def home():

    return render_template("index.html")


@app.route("/storage")
def storage():

    welcome_text = read_text_blob(
        "text",
        "welcome.txt"
    )

    services = read_json_blob(
        "data",
        "services.json"
    )

    images = list_images("images")

    return render_template(
        "storage.html",
        welcome_text=welcome_text,
        services=services,
        images=images
    )


@app.route("/sql")
def sql():

    messages = get_messages()

    return render_template(
        "sql.html",
        messages=messages
    )


if __name__ == "__main__":
    app.run(debug=True)


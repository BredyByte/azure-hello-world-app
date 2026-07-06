from flask import Flask, render_template

from storage import (
    read_text_blob,
    read_json_blob,
    list_blobs,
)

app = Flask(__name__)


@app.route("/")
def index():

    welcome = read_text_blob(
        "text",
        "welcome.txt"
    )

    app_info = read_json_blob(
        "data",
        "app-info.json"
    )

    services = read_json_blob(
        "data",
        "services.json"
    )

    images = list_blobs(
        "images"
    )

    return render_template(
        "index.html",
        welcome=welcome,
        app_info=app_info,
        services=services,
        images=images,
    )


if __name__ == "__main__":
    app.run(debug=True)

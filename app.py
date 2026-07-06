from flask import Flask, render_template

from storage import (
    read_text_blob,
    read_json_blob,
    list_blobs,
    get_blob_sas_url,
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

    image_names = list_blobs("images")

    images = [
        get_blob_sas_url("images", image)
        for image in image_names
    ]

    return render_template(
        "index.html",
        welcome=welcome,
        app_info=app_info,
        services=services,
        images=images,
    )


if __name__ == "__main__":
    app.run(debug=True)

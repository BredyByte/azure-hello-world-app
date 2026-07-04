from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <h1>Hello from Azure! 🚀</h1>
    <p>This is my first Azure App Service.</p>
    <p>Small changes added.</p>
    """

if __name__ == "__main__":
    app.run()

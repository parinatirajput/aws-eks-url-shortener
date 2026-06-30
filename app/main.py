from flask import Flask, request, jsonify, redirect
import random
import string

from database import save_url, get_url

app = Flask(__name__)


def generate_short_code(length=6):
    return ''.join(
        random.choices(
            string.ascii_letters + string.digits,
            k=length
        )
    )


@app.route("/")
def home():
    return "URL Shortener Running 🚀"


@app.route("/shorten", methods=["POST"])
def shorten():

    data = request.get_json()

    if not data or "url" not in data:
        return jsonify({
            "error": "URL is required"
        }), 400

    original_url = data["url"]

    short_code = generate_short_code()

    save_url(short_code, original_url)

    return jsonify({
        "original_url": original_url,
        "short_code": short_code,
        "short_url": f"http://localhost:5000/{short_code}"
    })


@app.route("/<short_code>")
def redirect_url(short_code):

    item = get_url(short_code)

    if not item:
        return jsonify({
            "error": "Short URL not found"
        }), 404

    return redirect(item["original_url"])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

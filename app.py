from flask import Flask
import os

app = Flask(__name__)

@app.get("/")
def hello():
    return {
        "message": "Hello from demo-app!",
        "hostname": os.getenv("HOSTNAME", "unknown")
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))

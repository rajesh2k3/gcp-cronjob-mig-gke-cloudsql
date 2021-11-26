from flask import Flask

from realcode import main 

app = Flask(__name__)

@app.route("/", methods=["POST"])
def execute():
    main.write_users()

    return("", 200)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
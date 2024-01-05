# accountservice.py
from flask import Flask

app = Flask(__name__)

@app.route('/accountservice')
def accountservice():
    return "¡Hola desde accountservice!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

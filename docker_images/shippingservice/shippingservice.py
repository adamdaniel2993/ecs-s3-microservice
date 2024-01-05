# shippingservice.py
from flask import Flask

app = Flask(__name__)

@app.route('/shippingservice')
def despedida():
    return "¡Adiós desde shippingservice!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)

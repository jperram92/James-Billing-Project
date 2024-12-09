from flask import Flask, request

app = Flask(__name__)

@app.route('/callback')
def callback():
    # Get the authorization code from the URL
    auth_code = request.args.get('code')
    return f'Authorization code received: {auth_code}'

if __name__ == '__main__':
    app.run(debug=True, port=8080)
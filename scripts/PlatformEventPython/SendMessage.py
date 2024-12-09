import os
import requests
from flask import Flask, request, redirect
from urllib.parse import urlencode

# Initialize Flask app
app = Flask(__name__)

# Define Salesforce OAuth details
CLIENT_ID = 'your_consumer_key'  # Your Salesforce Consumer Key
CLIENT_SECRET = 'your_consumer_secret'  # Your Salesforce Consumer Secret
REDIRECT_URI = 'http://localhost:8080/callback'  # The same as the callback URL you configured in Salesforce
AUTHORIZATION_URL = 'https://login.salesforce.com/services/oauth2/authorize'

# Step 1: Redirect user to Salesforce login page
@app.route('/')
def home():
    # Prepare Salesforce Authorization URL
    auth_url = f"{AUTHORIZATION_URL}?response_type=code&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}"
    return redirect(auth_url)

# Step 2: Handle redirect after successful login
@app.route('/callback')
def callback():
    # Salesforce sends the authorization code here
    code = request.args.get('code')

    if not code:
        return "Error: No code received"

    # Step 3: Exchange authorization code for access token
    token_url = 'https://login.salesforce.com/services/oauth2/token'
    payload = {
        'grant_type': 'authorization_code',
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'redirect_uri': REDIRECT_URI,
        'code': code,
    }

    # Send POST request to get access token
    response = requests.post(token_url, data=payload)

    if response.status_code == 200:
        # Successful authentication
        response_json = response.json()
        access_token = response_json['access_token']
        instance_url = response_json['instance_url']
        
        # Save access_token and instance_url for future use (you can save this to a file or database)
        with open('salesforce_token.txt', 'w') as file:
            file.write(f"Access Token: {access_token}\nInstance URL: {instance_url}")
        
        return "Authentication successful! Access token saved."
    else:
        return f"Error during authentication: {response.status_code}"

if __name__ == "__main__":
    app.run(port=8080)  # Make sure the port matches your Salesforce callback URL

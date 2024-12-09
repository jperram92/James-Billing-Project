import websocket
import json
import requests

# Salesforce Authentication Details
INSTANCE_URL = 'https://jdjd-dev-ed.develop.lightning.force.com'
CLIENT_ID = '3MVG9VMBZCsTL9hk4P0A0LQyXOn_5sYe6IkBKn3D131PrVKtT_tTmUVtbkdVY3MiKqCp4u2GaUEPNFnVL7XZY'
CLIENT_SECRET = '47B78F18DA47B321AB0391087C1545611830DADD56DD27208D7730E573800AB0'
USERNAME = 'jamesperramdeveloper@gmail.com'
PASSWORD = 'Hrcv2rje4!!!'  # Include your security token here if required.

# Authenticate with Salesforce using OAuth2
def authenticate():
    url = f"{INSTANCE_URL}/services/oauth2/token"
    payload = {
        "grant_type": "password",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "username": USERNAME,
        "password": PASSWORD,
    }
    response = requests.post(url, data=payload)
    response.raise_for_status()
    return response.json()

# Subscribe to Platform Events using WebSocket
def subscribe_to_events():
    auth_response = authenticate()
    access_token = auth_response["access_token"]
    instance_url = auth_response["instance_url"]

    # Salesforce CometD endpoint
    websocket_url = f"{instance_url}/cometd/54.0"

    # Establish a WebSocket connection
    ws = websocket.WebSocket()
    ws.connect(websocket_url, header={
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    })

    # Handshake with CometD
    handshake_message = [{
        "channel": "/meta/handshake",
        "version": "1.0",
        "supportedConnectionTypes": ["long-polling", "websocket"],
        "minimumVersion": "1.0",
    }]
    ws.send(json.dumps(handshake_message))
    print("Handshake response:", ws.recv())

    # Subscribe to the event channel
    subscribe_message = [{
        "channel": "/meta/subscribe",
        "subscription": "/event/Order_Notification__e",
        "id": "1"
    }]
    ws.send(json.dumps(subscribe_message))
    print("Subscription response:", ws.recv())

    # Listen for events
    while True:
        event = ws.recv()
        print("Received event:", event)

if __name__ == "__main__":
    subscribe_to_events()

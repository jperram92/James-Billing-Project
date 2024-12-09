import requests

# Define your Salesforce credentials and app details
CLIENT_ID = '3MVG9VMBZCsTL9hk4P0A0LQyXOrrXMS0cjif5xzamrByz31mRoEKph61muUW.mnwf354.oV9SvBFNRkvyyFmH'  # Use your Consumer Key
CLIENT_SECRET = 'BFDE636CDFBE2AC7097342534118B7444136491B43794127DB441BF465C3AC30'  # Use your Consumer Secret
USERNAME = 'jamesperramdeveloper@gmail.com'  # Replace with your Salesforce username
PASSWORD = 'Hrcv2rje4!!!' + 'ya8qnw9ZCUrDa3UKaJZjpohkG'  # Ensure no space

# Salesforce OAuth2 token URL
url = 'https://login.salesforce.com/services/oauth2/token'  # Use the correct Salesforce instance URL
# If you're using a sandbox, change this URL to:
# url = 'https://test.salesforce.com/services/oauth2/token'

# Create the payload with the required parameters
payload = {
    'grant_type': 'password',
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET,
    'username': USERNAME,
    'password': PASSWORD,
}

# Send the POST request to Salesforce for authentication
response = requests.post(url, data=payload)

# Check if the request was successful
if response.status_code == 200:
    # Parse the response JSON
    response_json = response.json()
    access_token = response_json.get('access_token')
    instance_url = response_json.get('instance_url')
    
    print('Authentication successful!')
    print('Access Token:', access_token)
    print('Instance URL:', instance_url)
else:
    print('Error during authentication:', response.status_code)
    print('Response:', response.text)  # This will print out detailed error information to help debug

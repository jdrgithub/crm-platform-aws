import os
import requests
from requests_aws4auth import AWS4Auth
import boto3

# This script sends a signed POST request to the API Gateway endpoint as an unauthenticated guest user.
# AWS requires all API Gateway requests to be signed using Signature Version 4 (SigV4).
# We use `requests-aws4auth` to generate this signature.

# This assumes you've already run `get_guest_credentials.py` and exported the credentials to environment variables.
session = boto3.Session()
credentials = session.get_credentials()

if credentials is None:
    raise RuntimeError("AWS credentials not found. Run the get_guest_credentials.py auth script first or set environment variables.")

frozen = credentials.get_frozen_credentials()

region = "us-east-1"
service = "execute-api"

# Generate an AWS4Auth object that signs requests with your temporary credentials
auth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    region,
    service,
    session_token=credentials.token
)

# Target API Gateway endpoint for creating a new contact
url = "https://mn3vl1gj67.execute-api.us-east-1.amazonaws.com/dev/contacts"
data = {
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "123-456-7890",
    "position_applied": "DevOps Engineer",
    "recruiter_company": "Awesome Recruiters Inc.",
    "last_contacted": "2024-06-01",
    "next_follow_up": "2024-06-10",
    "status": "In Progress",
    "notes": "Had phone screen; follow-up next week"
}

# Make the signed POST request
response = requests.post(url, json=data, auth=auth)

# Output the result
print(response.status_code)
print(response.text)

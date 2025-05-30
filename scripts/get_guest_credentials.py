# get_guest_credentials.py
# Gets access key, secret key, and session token for unauth guest user
# Run like this -> eval $(python3 get_guiest_credentials.py)
# After -> run test_post.py script

import boto3
import os

# Identity Pool ID
identity_pool_id = "us-east-1:0d9dfd84-6873-459b-b98c-58860fbde85f"

# Get identity ID
identity_client = boto3.client("cognito-identity")
identity_id = identity_client.get_id(IdentityPoolId=identity_pool_id)["IdentityId"]

# Get temporary credentials
credentials = identity_client.get_credentials_for_identity(IdentityId=identity_id)["Credentials"]

# Export them as shell-compatible exports
print("export AWS_ACCESS_KEY_ID='{}'".format(credentials["AccessKeyId"]))
print("export AWS_SECRET_ACCESS_KEY='{}'".format(credentials["SecretKey"]))
print("export AWS_SESSION_TOKEN='{}'".format(credentials["SessionToken"]))

# Minimal script to authenticate as guest user to Cognito Identity Pool to test

import boto3

# Cognito Identity Pool ID (replace later when needed)
identity_pool_id = "us-east-1:0d9dfd84-6873-459b-b98c-58860fbde85f"

# Create a client for the Cognito Identity service
identity_client = boto3.client("cognito-identity")

# STEP 1 -> Get a unique identity ID for a guest (unauthenticated) user
# Tell Cognito to start a session as an unauthed user from pool
identity_response = identity_client.get_id(
    IdentityPoolId=identity_pool_id
)

# Extract generated Identity ID from response
identity_id = identity_response["IdentityId"]

# STEP 2 -> Exchange identity ID for temporary AWS credentials
# Can be used to sign AWS requests based on perms in unauthed role)
credentials_response = identity_client.get_credentials_for_identity(
    IdentityId=identity_id
)

# Print returned credentials (AccessKeyId, SecretKey, SessionToken, and Expiration)
print("Temporary guest credentials:")
for key, value in credentials_response["Credentials"].items():
  print(f"{key}: {value}")


  

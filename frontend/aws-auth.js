// aws-auth.js

/**
 * Configuration for Cognito Identity Pool
 */
const REGION = "us-east-1";
const IDENTITY_POOL_ID = "us-east-1:0d9dfd84-6873-459b-b98c-58860fbde85f";

/**
 * Initializes AWS SDK for browser with unauthenticated guest credentials
 * Returns promise that resolves when credentials are ready
 */
function initializeAwsGuestAuth() {
  return new Promise((resolve, reject) => {
    AWS.config.region = REGION;

    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
      IdentityPoolId: IDENTITY_POOL_ID,
    });

    AWS.config.credentials.get((err) => {
      if (err) {
        console.error("Failed to get AWS credentials", err);
        reject(err);
      } else {
        console.log("Successfully retrieved AWS guest credentials");
        resolve(AWS.config.credentials);
      }
    });
  });
}

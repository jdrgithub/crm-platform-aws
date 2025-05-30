import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE")

if not table_name:
    raise ValueError("DYNAMODB_TABLE environment variable is not set")
  
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    contact_id = event.get("pathParameters", {}).get("contact_id")

    if not contact_id:
        return {
            "statusCode": 400,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            "body": json.dumps({"error": "Missing contact_id in path"})
        }

    try:
        table.delete_item(
            Key={"contact_id": contact_id}
        )
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            "body": json.dumps({"message": f"Contact {contact_id} deleted"})
        }

    except ClientError as e:
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            "body": json.dumps({"error": str(e)})
        }


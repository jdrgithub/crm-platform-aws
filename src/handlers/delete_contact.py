import json
import boto3
import os
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE")

if not table_name:
    raise ValueError("DYNAMODB_TABLE environment variable is not set")

table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    contact_id = event.get("pathParameters", {}).get("contact_id")

    if not contact_id:
        logger.warning("Missing contact_id in pathParameters")
        return {
            "statusCode": 400,
            "headers": cors_headers(),
            "body": json.dumps({"error": "Missing contact_id in path"})
        }

    try:
        response = table.delete_item(
            Key={"contact_id": contact_id},
            ConditionExpression="attribute_exists(contact_id)"
        )
        logger.info(f"DeleteItem response: {response}")

        return {
            "statusCode": 200,
            "headers": cors_headers(),
            "body": json.dumps({"message": f"Contact {contact_id} deleted"})
        }

    except ClientError as e:
        logger.error(f"ClientError: {e}")
        error_response = getattr(e, "response", {})
        error_code = error_response.get("Error", {}).get("Code", "")

        if error_code == "ConditionalCheckFailedException":
            return {
                "statusCode": 404,
                "headers": cors_headers(),
                "body": json.dumps({"error": f"Contact {contact_id} not found"})
            }
        return {
            "statusCode": 500,
            "headers": cors_headers(),
            "body": json.dumps({"error": str(e)})
        }
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "headers": cors_headers(),
            "body": json.dumps({"error": "Internal server error"})
        }

def cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type"
    }

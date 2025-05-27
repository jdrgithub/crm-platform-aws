# pyright: reportAttributeAccessIssue=false
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def save_contact(contact):
    table.put_item(Item=contact.to_dict())

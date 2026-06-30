import boto3
import os

TABLE_NAME = os.getenv("DYNAMODB_TABLE", "url-shortener")
AWS_REGION = os.getenv("AWS_REGION", "ap-south-1")

dynamodb = boto3.resource(
    "dynamodb",
    region_name=AWS_REGION
)

table = dynamodb.Table(TABLE_NAME)


def save_url(short_code, original_url):
    table.put_item(
        Item={
            "short_code": short_code,
            "original_url": original_url
        }
    )


def get_url(short_code):
    response = table.get_item(
        Key={
            "short_code": short_code
        }
    )

    return response.get("Item")

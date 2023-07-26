import json
import boto3

def lambda_handler(event, context):
    if event['requestContext']['http']['method'] == 'GET':
        # Get all products from DynamoDB
        client = boto3.client('dynamodb')
        response = client.scan(TableName='products')
        products = response['Items']

        # Return the products as JSON
        return {'products': products}

    elif event['requestContext']['http']['method'] == 'POST':
        # Get the product from the event
        product = json.loads(event['body'])
        
        # Set the attribute types for put_item
        newProduct = { 'id': {}, 'name': {} , 'price': {}}
        newProduct['id']['S'] = product['id']
        newProduct['name']['S'] = product['name']
        newProduct['price']['S'] = product['price']

        # Add the product to DynamoDB
        client = boto3.client('dynamodb')
        response = client.put_item(TableName='products', Item=newProduct)

        # Return a success message
        return {'message': 'Product added successfully'}
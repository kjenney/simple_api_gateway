# simple-api-gateway

A simple implementation of API gateway with GET and POST reading and writing to DynamoDB.

This example uses products where `id`, `name`, and `price` are stored in a DynamoDB table.

## To deploy run:

```
terraform init
terraform apply
```

## To test the API:

Use the `api_url` output from Terraform apply.

To add a product to the table:

`curl -d '{"id":"78911", "name":"Yogurt", "price":"2.45"}' -H "Content-Type: application/json" -X POST {api_url}`

To get a list of products in the table:

`curl {api_url}`


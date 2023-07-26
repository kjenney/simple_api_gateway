provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "products" {
  name = "products"
  hash_key = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "id"
    type = "S"
  }
}

module "products_lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "5.3.0"

  function_name = "products"
  description   = "Read and write products"
  handler       = "products.lambda_handler"
  runtime       = "python3.8"

  source_path = "./lambda"

  attach_policy = true
  policy        = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"

  tags = {
    Name = "Products"
  }
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name          = "Products"
  description   = "My awesome Products API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name     = false
  create_default_stage       = true

  integrations = {

    "ANY /" = {
      lambda_arn             = module.products_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.products_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
}
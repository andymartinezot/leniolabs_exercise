###########################
##### LAMBDA FUNCTION #####
###########################

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
}

data "archive_file" "zip_lambda" {
  type        = "zip"
  source_file = "src/code.py"
  output_path = "src/code.zip"
}

resource "aws_lambda_function" "leniolabs_lambda" {
  function_name = var.lambda_function_name

  filename         = data.archive_file.zip_lambda.output_path
  source_code_hash = data.archive_file.zip_lambda.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  handler = "src.code.lambda_handler"
  runtime = "python3.8"
}

###########################
#####   API GATEWAY   #####
###########################

resource "aws_apigatewayv2_api" "leniolabs_apigw" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "leniolabs_lambda_integration" {
  api_id             = aws_apigatewayv2_api.leniolabs_apigw.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.leniolabs_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "leniolabs_lambda_route" {
  api_id    = aws_apigatewayv2_api.leniolabs_apigw.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.leniolabs_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "leniolabs_lambda_stage" {
  api_id      = aws_apigatewayv2_api.leniolabs_apigw.id
  name        = "dev"
  auto_deploy = true
}

###########################
##### DYNAMODB TABLE  #####
###########################

resource "aws_dynamodb_table" "leonilabs_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_time"

  attribute {
    name = "event_time"
    type = "S" # Assuming the value attribute is a string, adjust as needed
  }

  #   attribute {
  #     name = "event_description"
  #     type = "S" # Assuming the value attribute is a string, adjust as needed
  #   }

  ttl {
    attribute_name = "ttl_attribute"
    enabled        = false
  }
}
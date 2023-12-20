# Terraform Infrastructure for LenioLabs test
This Terraform configuration sets up an AWS infrastructure for LenioLabs, including a Lambda function, API Gateway, and a DynamoDB table.

## Lambda Function
### IAM Role
A new IAM role named lambda_role is created with a policy document allowing Lambda to assume the role.

### Lambda Function
A Lambda function named leniolabs_lambda is created with the following configurations:

* Function Name: Specified by the variable var.lambda_function_name.
* Runtime: Python 3.8
* Handler: src.code.lambda_handler
* Source Code: The function code is sourced from the file src/code.py, which is zipped and stored as src/code.zip.
* Role: The Lambda function assumes the IAM role lambda_role.

In summary, the Lambda function inserts data into DynamoDB and retrieves it, generating a greeting message with the current date and time.

## API Gateway
An API Gateway named leniolabs_apigw is created with the following components:

### Integration
An integration named leniolabs_lambda_integration is configured to integrate with the Lambda function. It uses the AWS_PROXY integration type for a POST method.

### Route
A route named leniolabs_lambda_route is defined with a default route key, linking to the previously configured integration.

### Stage
A stage named leniolabs_lambda_stage is created for the dev environment, and it automatically deploys changes.

## DynamoDB Table
A DynamoDB table named leonilabs_table is created with the following configurations:

* Table Name: Specified by the variable var.dynamodb_table_name.
* Billing Mode: PAY_PER_REQUEST
* Hash Key: event_time
* Attributes: An attribute named event_time of type string is defined.
* TTL: Time-To-Live feature is disabled.

## Usage
To apply this Terraform configuration, ensure you have AWS credentials configured and execute the following commands:

    ```
    terraform fmt --recursive .
    terraform init
    terraform validate
    terraform apply -auto-approve
    ``` 

from datetime import datetime
import boto3

# Replace 'your_table_name' with the actual name of your DynamoDB table
TABLE_NAME = 'leonilabs_table'
key_attribute_name = 'event_time'
value_attribute_name = 'event_description'

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')

def lambda_handler():
    # Get the current date and time
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Insert data into DynamoDB
    insert_data_into_dynamodb(current_time)
    
    # Get data from DynamoDB
    retrieved_data = get_data_from_dynamodb()
    
    #Create a greeting message
    message = f"Hello! The current date and time are: {current_time}. Retrieved data from DynamoDB: {retrieved_data}"
    
    return message

#Function to insert data into the dynamo DB table.
def insert_data_into_dynamodb(current_time):
    # Get the DynamoDB table
    table = dynamodb.Table(TABLE_NAME)

    # Insert data into DynamoDB
    table.put_item(
        Item={
            key_attribute_name: current_time,
            value_attribute_name: "Some value associated with the current time",
        }
    )

def get_data_from_dynamodb():
    # Get the DynamoDB table
    table = dynamodb.Table(TABLE_NAME)

    # Replace 'some_key_value' with the actual key value you want to retrieve
    key_value = datetime.now().strftime("%Y-%m-%d")

    # Get data from DynamoDB
    response = table.get_item(
        Key={
            key_attribute_name: key_value,
        }
    )

    # Extract the retrieved data
    retrieved_data = response.get('Item', {}).get(value_attribute_name, None)

    return retrieved_data


# result = lambda_handler()
# print(result)

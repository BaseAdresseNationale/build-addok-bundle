#!/bin/bash

set -e  # Stop the script on error

# Ensure necessary directories exist
mkdir -p data dist

# Set environment variables
export S3_PATH_INPUT_FILE_PATH=$S3_ADDOK_PATH/$S3_INPUT_FILE_NAME
export LOCAL_INPUT_FILE_PATH=data/$S3_INPUT_FILE_NAME

export S3_OUTPUT_FILE_PATH=$S3_ADDOK_PATH/$S3_OUTPUT_FILE_NAME
export LOCAL_OUTPUT_FILE_PATH=dist/$S3_OUTPUT_FILE_NAME

# Authenticate to AWS using environment variables
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

# Download file from S3
echo "Downloading file from s3..."
aws --endpoint-url $S3_ENDPOINT_URL s3 cp s3://$S3_BUCKET/$S3_PATH_INPUT_FILE_PATH $LOCAL_INPUT_FILE_PATH || { echo "Error: Unable to download $LOCAL_INPUT_FILE_PATH"; exit 1; }

# Unzip input file and build addok.db
echo "Building addok database..."
gunzip -c "$LOCAL_INPUT_FILE_PATH" | addok batch || { echo "Error: addok batch failed"; exit 1; }
addok ngrams

# Ensure Redis saves dump.rdb
echo "Saving Redis database..."
redis-cli save || { echo "Error: Redis save failed"; exit 1; }

# Zip and upload addok bundle to S3
echo "Uploading addok bundle to s3..."
zip -j "$LOCAL_OUTPUT_FILE_PATH" dist/addok.db dist/dump.rdb "$ADDOK_CONFIG_MODULE" || { echo "Error: zip failed"; exit 1; }
aws --endpoint-url $S3_ENDPOINT_URL s3 cp "$LOCAL_OUTPUT_FILE_PATH" s3://$S3_BUCKET/$S3_OUTPUT_FILE_PATH || { echo "Error: S3 upload failed"; exit 1; }

echo "Addok bundle uploaded to S3."

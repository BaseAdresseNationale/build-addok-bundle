#!/bin/bash

# Set environment variables
export S3_PATH_INPUT_FILE_PATH=$S3_ADDOK_PATH/$S3_INPUT_FILE_NAME
export LOCAL_INPUT_FILE_PATH=data/$S3_INPUT_FILE_NAME

export S3_OUTPUT_FILE_PATH=$S3_ADDOK_PATH/$S3_OUTPUT_FILE_NAME
export LOCAL_OUTPUT_FILE_PATH=dist/$S3_OUTPUT_FILE_NAME

# Authenticate to AWS
aws configure set aws_access_key_id $S3_ACCESS_KEY_ID
aws configure set aws_secret_access_key $S3_SECRET_ACCESS_KEY
aws configure set aws_default_region $S3_REGION

# Download file adresses-addok-france.ndjson.gz from s3
echo "Downloading file from s3..."
aws --endpoint-url $S3_ENDPOINT_URL s3 cp s3://$S3_BUCKET/$S3_PATH_INPUT_FILE_PATH $LOCAL_INPUT_FILE_PATH

# Unzip input file and build addok.db
echo "Building addok database..."
gunzip -c $LOCAL_INPUT_FILE_PATH | addok batch
addok ngrams

# Save addok database to dump.rdb
redis-cli shutdown save

# Zip and upload addok bundle to s3
echo "Uploading addok bundle to s3..."
zip -j $LOCAL_OUTPUT_FILE_PATH dist/addok.db dist/dump.rdb $ADDOK_CONFIG_MODULE
aws --endpoint-url $S3_ENDPOINT_URL s3 cp $LOCAL_OUTPUT_FILE_PATH s3://$S3_BUCKET/$S3_OUTPUT_FILE_PATH

echo "Addok bundle uploaded to s3."
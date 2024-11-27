#!/bin/bash

# Variables
BUCKET_NAME="terraform-github-runner-tf-state-backend"
DYNAMODB_TABLE_NAME="terraform-state-locking-table"
REGION="ap-south-1"

# Check if DynamoDB table exists
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" --region "$REGION" &>/dev/null; then
  echo "DynamoDB table $DYNAMODB_TABLE_NAME exists."

  aws dynamodb delete-table --table-name "$DYNAMODB_TABLE_NAME" --region "$REGION"
fi

# Check if S3 bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" &>/dev/null; then
  echo "S3 bucket $BUCKET_NAME exists."

  aws s3api list-object-versions --bucket "$BUCKET_NAME" --output text --query 'Versions[*].[Key,VersionId]' | \
  grep -v "None" | while read -r key versionId; do
    if [[ -n "$versionId" && "$versionId" != "None" ]]; then
      aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$versionId"
    fi
  done

  aws s3api list-object-versions --bucket "$BUCKET_NAME" --output text --query 'DeleteMarkers[*].[Key,VersionId]' | \
  grep -v "None" | while read -r key versionId; do
    if [[ -n "$versionId" && "$versionId" != "None" ]]; then
      aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$versionId"
    fi
  done

  aws s3api list-object-versions --bucket "$BUCKET_NAME"

  aws s3 rb s3://"$BUCKET_NAME"
fi
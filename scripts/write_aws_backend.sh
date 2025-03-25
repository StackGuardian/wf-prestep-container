#!/bin/bash

# Write the backend configuration to backend.tf

bucket=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.bucket')
key=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.key')
region=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.region')
dynamodb_table=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.dynamodb_table')
filepath_backend=${MOUNTED_IAC_SOURCE_CODE_DIR}"/backend.tf"

read -r -d '' backendcontent << EOF
terraform {
  backend "s3" {
    bucket         = "$bucket"
    key            = "$key"
    region         = "$region"
    encrypt        = true
    dynamodb_table = "$dynamodb_table"
  }
}
EOF

printf "%b" "$backendcontent" > "$filepath_backend" 2>/dev/null;

cat $filepath_backend

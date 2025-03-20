#!/bin/bash

resource_group_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.resource_group_name')
storage_account_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.storage_account_name')
container_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.container_name')
statefilename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.statefilename')
filepath_backend=${MOUNTED_IAC_SOURCE_CODE_DIR}"/backend.tf"

read -r -d '' backendcontent << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$resource_group_name"
    storage_account_name = "$storage_account_name"
    container_name       = "$container_name"
    key                  = "$statefilename"
  }
}
EOF

printf "%b" "$backendcontent" > "$filepath_backend" 2>/dev/null;

cat $filepath_backend
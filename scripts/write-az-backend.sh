#!/bin/bash

################################################################################
# Input paramters which must be set in the template
#
# resource_group_name -> Name of the Resource Group in which the Storage Account
#                        is located
# storage_account_name -> Name of the Storage Account
# container_name -> Name of the container iun the Storage Account
# statefilename -> Name of the state file, including the "path"
################################################################################

# Write the backend configuration to backend.tf

# Check if the resource group name is set in the environment variable or in the input variables
if [ -v BACKEND_RESOURCE_GROUP_NAME ]; then
  resource_group_name=$BACKEND_RESOURCE_GROUP_NAME
else
  resource_group_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.resource_group_name')
fi

# Check if the storage account name is set in the environment variable or in the input variables
if [ -v BACKEND_STORAGE_ACCOUNT_NAME ]; then
  storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME
else
  storage_account_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.storage_account_name')
fi

# Check if the container name is set in the environment variable or in the input variables
if [ -v BACKEND_CONTAINER_NAME ]; then
  container_name=$BACKEND_CONTAINER_NAME
else
  container_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.container_name')
fi

# Check if the statefilename is set in the environment variable or in the input variables

if [ -v BACKEND_STATE_FILENAME ]; then
  statefilename=$BACKEND_STATE_FILENAME
elif ["$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.use_default_statefile')"=="false"]; then
  statefilename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.statefilename')
else
  statefilename=${SG_WORKFLOW_ID}
fi

filepath_backend=${MOUNTED_IAC_SOURCE_CODE_DIR}"/backend.tf"

read -r -d '' backendcontent << EOF
terraform {
  backend "azurerm" {
    use_azuread_auth     = true
    resource_group_name  = "$resource_group_name"
    storage_account_name = "$storage_account_name"
    container_name       = "$container_name"
    key                  = "$statefilename"
  }
}
EOF

printf "%b" "$backendcontent" > "$filepath_backend" 2>/dev/null;

cat $filepath_backend

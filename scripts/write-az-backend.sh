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

resource_group_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.resource_group_name')
storage_account_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.storage_account_name')
container_name=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.container_name')
statefilename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.statefilename')
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

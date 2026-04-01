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
elif [ "$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.use_default_statefile')" == "false" ]; then
  statefilename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.statefilename')
else
  statefilename=${SG_WORKFLOW_ID}
fi

# Download the terraform state file from the backend storage account
filepath_statefile=${SG_MOUNTED_ARTIFACTS_DIR}"/tfstate.json"

echo "Downloading state file '${statefilename}' from storage account '${storage_account_name}' container '${container_name}'..."

# Authenticate using OIDC token
az login --federated-token "$SG_OIDC_TOKEN" --service-principal \
  --username "$ARM_CLIENT_ID" --tenant "$ARM_TENANT_ID"

az storage blob download \
  --account-name "$storage_account_name" \
  --container-name "$container_name" \
  --name "$statefilename" \
  --file "$filepath_statefile" \
  --auth-mode login

echo "AFTER: current files in ${SG_MOUNTED_ARTIFACTS_DIR}:"
ls -la ${SG_MOUNTED_ARTIFACTS_DIR}

echo "***************************************************************"



if [ $? -eq 0 ]; then
  echo "State file downloaded successfully to ${filepath_statefile}"
else
  echo "ERROR: Failed to download state file" >&2
  exit 1
fi

# Validate required environment variables
if [ -z "$SG_Workflow_Rename_API_Token" ]; then
  echo "ERROR: SG_Workflow_Rename_API_Token environment variable is not set" >&2
  exit 1
fi
API_BASE_URL="https://api.app.stackguardian.io/api/v1"
AUTH_HEADER="Authorization: apikey $SG_Workflow_Rename_API_Token"

echo "Fetching workflow configuration for workflow: $WORKFLOW_ID in org: $SG_ORG_ID"

# Fetch the workflow configuration
WORKFLOW_CONFIG=$(curl -s -X GET \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  "$API_BASE_URL$SG_ORG_ID$WORKFLOW_ID")

echo "Current workflow configuration:"
echo "$WORKFLOW_CONFIG" | jq '.'

# Verify the API response
if echo "$WORKFLOW_CONFIG" | jq -e '.data' > /dev/null 2>&1; then
  echo "Successfully fetched workflow configuration"
else
  echo "ERROR: Failed to fetch workflow configuration" >&2
  echo "$WORKFLOW_CONFIG" | jq '.' >&2
  exit 1
fi

UPDATED_CONFIG=$(echo "$WORKFLOW_CONFIG" | jq '
  .data.config |= (
    # Set backend to SG managed backend
    .backend = "SG_MANAGED" |
    # Remove pre-plan workflowstep
    .workflowSteps |= map(select(.stepType != "pre-plan" and .name != "pre-plan"))
  )
')
echo "UPDATED_CONFIG: $UPDATED_CONFIG"

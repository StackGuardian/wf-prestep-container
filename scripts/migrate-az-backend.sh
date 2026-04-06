#!/bin/bash

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

# Build a patch payload containing only the changed TerraformConfig
PATCH_PAYLOAD=$(echo "$WORKFLOW_CONFIG" | jq '{
  TerraformConfig: (
    .msg.TerraformConfig |
    .managedTerraformState = true |
    .prePlanWfStepsConfig |= map(select(.wfStepTemplateId | startswith("/stackguardian/PreStep-create-az-backend") | not))
  )
}')

echo "Patch payload:"
echo "$PATCH_PAYLOAD" | jq '.'

# Push the updated configuration back to the API
echo ""
echo "Pushing updated configuration back to the API..."

UPDATE_RESPONSE=$(curl -s -X PATCH \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/json" \
  -d "$PATCH_PAYLOAD" \
  "$API_BASE_URL$SG_ORG_ID$WORKFLOW_ID")

echo "API Response:"
echo "$UPDATE_RESPONSE" | jq '.'

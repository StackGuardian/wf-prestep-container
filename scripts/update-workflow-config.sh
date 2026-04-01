#!/bin/bash

################################################################################
# Script to fetch, update, and push workflow configuration via StackGuardian API
# 
# Environment variables required:
# - SG_API_TOKEN: StackGuardian API token
# - WORKFLOW_ID: The workflow ID to update
# - SG_ORG_ID: The organization name/ID
################################################################################

set -e

# Validate required environment variables
if [ -z "$SG_Workflow_Rename_API_Token" ]; then
  echo "ERROR: SG_Workflow_Rename_API_Token environment variable is not set" >&2
  exit 1
fi

if [ -z "$WORKFLOW_ID" ]; then
  echo "ERROR: WORKFLOW_ID environment variable is not set" >&2
  exit 1
fi

if [ -z "$SG_ORG_ID" ]; then
  echo "ERROR: SG_ORG_ID environment variable is not set" >&2
  exit 1
fi

# API configuration
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

# Update the configuration:
# 1. Change backend to SG managed backend
# 2. Remove pre-plan workflowstep

UPDATED_CONFIG=$(echo "$WORKFLOW_CONFIG" | jq '
  .data.config |= (
    # Set backend to SG managed backend
    .backend = "SG_MANAGED" |
    # Remove pre-plan workflowstep
    .workflowSteps |= map(select(.stepType != "pre-plan" and .name != "pre-plan"))
  )
')
# echo "UPDATED_CONFIG: $UPDATED_CONFIG"

# echo ""
# echo "Updated workflow configuration:"
# echo "$UPDATED_CONFIG" | jq '.data.config'

# echo ""
# echo "----------------------------------------------------"
# echo ""
# echo $UPDATED_CONFIG | jq '.'

# # Push the updated configuration back to the API
# echo ""
# echo "Pushing updated configuration back to the API..."

# UPDATE_RESPONSE=$(curl -s -X PATCH \
#   -H "$AUTH_HEADER" \
#   -H "Content-Type: application/json" \
#   -d "$UPDATED_CONFIG" \
#   "$API_BASE_URL$SG_ORG_ID$WORKFLOW_ID")

# echo "API Response:"
# echo "$UPDATE_RESPONSE" | jq '.'

# # Verify the update was successful
# if echo "$UPDATE_RESPONSE" | jq -e '.data' > /dev/null 2>&1; then
#   echo ""
#   echo "✓ Successfully updated workflow configuration!"
#   echo "  - Backend changed to SG_MANAGED"
#   echo "  - Pre-plan workflowstep removed"
# else
#   echo "ERROR: Failed to update workflow configuration" >&2
#   exit 1
# fi

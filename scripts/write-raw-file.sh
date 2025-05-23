#!/bin/bash

# Writing the raw file to the mounted directory
################################################################################
# Input paramters which must be set in the template
#
# filecontent -> The content of the file to be written
# filename -> The name of the file to be written
################################################################################

filecontent=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.filecontent')
filename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq -r '.filename')

filepath="${MOUNTED_IAC_SOURCE_CODE_DIR}"/"${filename}"

printf "%b" "$filecontent" > "$filepath" 2>/dev/null;

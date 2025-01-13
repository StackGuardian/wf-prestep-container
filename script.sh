#!/bin/bash

filecontent=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq '.filecontent')

filename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq '.filename')

filepath="${MOUNTED_IAC_SOURCE_CODE_DIR}/$filename"

#printf "%s" "$filecontent" > "$filepath" 2>/dev/null;

echo "Filecontent \n######################\n"
echo $filecontent
echo "\n\nFilename \n######################\n"
echo $filename
echo "\n\nFilepath \n######################\n"
echo $filepath
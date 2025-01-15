#!/bin/bash

printf '\n\nENV \n######################\n'
printenv

filecontent=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq '.filecontent')
filename=$(echo $SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES | base64 --decode | jq '.filename')
filepath="${MOUNTED_IAC_SOURCE_CODE_DIR}"/$(printf "%s" $filename | tr -d '"' $filename)

#printf "%s" "$filecontent" > "$filepath" 2>/dev/null;

printf '\n\nFilecontent \n######################\n'
printf "%b" $filecontent
printf '\n\nFilename \n######################\n'
printf $filename
printf '\n\nFilepath \n######################\n'
printf $filepath

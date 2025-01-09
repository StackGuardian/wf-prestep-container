#!/bin/bash


if [ -n "$SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES" ]; then
  echo "Decoding SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES:"
  echo "$SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES" | base64 -d | jq
else
  echo "SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES is not set."
fi

echo ""

if [ -n "$SG_BASE64_IAC_INPUT_VARIABLES" ]; then
  echo "Decoding SG_BASE64_IAC_INPUT_VARIABLES:"
  echo "$SG_BASE64_IAC_INPUT_VARIABLES" | base64 -d | jq
else
  echo "SG_BASE64_IAC_INPUT_VARIABLES is not set."
fi

ls -l $MOUNTED_IAC_SOURCE_CODE_DIR

cat $MOUNTED_IAC_SOURCE_CODE_DIR/backend.tf

echo "\n Trenner \n\n"

cat $MOUNTED_IAC_SOURCE_CODE_DIR/provider.tf

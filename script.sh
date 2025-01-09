#!/bin/bash

# Base64-dekodierte Umgebungsvariablen
if [ -n "$SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES" ]; then
  echo "Decoding SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES:"
  echo "$SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES" | base64 -d
else
  echo "SG_BASE64_WORKFLOW_STEP_INPUT_VARIABLES is not set."
fi

echo ""

if [ -n "$SG_BASE64_IAC_INPUT_VARIABLES" ]; then
  echo "Decoding SG_BASE64_IAC_INPUT_VARIABLES:"
  echo "$SG_BASE64_IAC_INPUT_VARIABLES" | base64 -d
else
  echo "SG_BASE64_IAC_INPUT_VARIABLES is not set."
fi
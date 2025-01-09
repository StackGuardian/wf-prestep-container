#!/bin/bash

# Prüfen, ob jq installiert ist
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is not installed. Please install it (e.g., 'apt-get install jq') and try again."
  exit 1
fi

# Base64-dekodierte Umgebungsvariablen verarbeiten
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
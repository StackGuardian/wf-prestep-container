#!/bin/bash

filepath_provider=${MOUNTED_IAC_SOURCE_CODE_DIR}"/provider.tf"

read -r -d '' providercontent << EOF
provider "azurerm" {
  features {}
}
EOF

printf "%b" "$providercontent" > "$filepath_provider" 2>/dev/null;

cat $filepath_provider

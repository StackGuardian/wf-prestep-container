#!/bin/bash

if [ -e "${MOUNTED_IAC_SOURCE_CODE_DIR}/provider.tf.txt" ]; then
  mv "${MOUNTED_IAC_SOURCE_CODE_DIR}/provider.tf.txt" "${MOUNTED_IAC_SOURCE_CODE_DIR}/provider.tf"
else
  echo "File ${MOUNTED_IAC_SOURCE_CODE_DIR}/provider.tf.txt does not exist."
fi
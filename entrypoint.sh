#!/bin/bash

set -euo pipefail

cd /build

if [ -f cert.crt ]; then
  echo "Adding custom certificate..."
  cp cert.crt /usr/local/share/ca-certificates/custom-ca/
  sudo update-ca-certificates
fi

if [ ! -z "${AZ_URL:-}" ]; then
  # Azure DevOps Agent build
  exit $(./agent.sh)
else
  # Custom build
  exit $(./build.sh)
fi
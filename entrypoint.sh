#!/bin/bash

set -euo pipefail

cd /build

if [ -f cert.crt ]; then
  echo "Adding custom certificate..."
  mkdir -p /usr/local/share/ca-certificates/custom-ca
  cp cert.crt /usr/local/share/ca-certificates/custom-ca/
  update-ca-certificates
fi

if [ ! -z "${AZ_URL:-}" ]; then
  # Azure DevOps Agent build
  exit $(./agent.sh)
else
  # Custom build
  exit $(./build.sh)
fi
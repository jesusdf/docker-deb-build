#!/bin/bash

set -euo pipefail

cd /build

if [ ! -z "${AZ_URL:-}" ] then
  # Azure DevOps Agent build
  exit $(./agent.sh)
else
  # Custom build
  exit $(./build.sh)
fi
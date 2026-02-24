#!/bin/bash

set -euo pipefail

cd /build

if [ -f cert.crt ]; then
  echo "Adding custom certificate..."
  cp cert.crt /usr/local/share/ca-certificates/custom-ca/
  sudo update-ca-certificates
fi

if [ -f /var/run/docker.sock ]; then
  # Fix group id so it matches the host docker socket permissions
  NEWGID=$(stat -c '%g' /var/run/docker.sock)
  sudo groupmod -g $NEWGID docker
fi

if [ ! -z "${AZ_URL:-}" ]; then
  # Azure DevOps Agent build
  bash agent.sh
else
  # Custom build
  bash build.sh
fi
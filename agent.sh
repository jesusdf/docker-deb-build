#!/bin/bash

set -euo pipefail

if [ -z "${AZ_URL:-}" ] then
  echo "ERROR: AZ_URL must be set"
  exit 1
fi

if [ "${AZ_AUTH_TYPE:-}"=="pat" ]; then
  if [ -z "${AZ_TOKEN:-}" ]; then
    echo "ERROR: AZ_TOKEN must be set"
    exit 1
  fi
else
  if [ -z "${AZ_USER:-}" ] || [ -z "${AZ_PASS:-}" ]; then
    echo "ERROR: AZ_USER and AZ_PASS must be set"
    exit 1
  fi
fi

# Default values
AZ_POOL=${AZ_POOL:-Default}
AZ_AGENT_NAME=${AZ_AGENT_NAME:-$(hostname)}

cleanup() {

  if [ -f ".agent" ]; then

    echo ">> Removing existing agent configuration"
    if [ "${AZ_AUTH_TYPE:-}"=="pat" ]; then
        
        ./config.sh remove --unattended \
            --url   "$AZ_URL" \
            --auth  "$AZ_AUTH_TYPE" \
            --token "$AZ_TOKEN"

        # clean up any leftover state
        rm -rf _work externals .credentials .agent
    
    else

        ./config.sh remove --unattended \
            --url   "$AZ_URL" \
            --auth  "$AZ_AUTH_TYPE" \
            --user  "$AZ_USER" \
            --password "$AZ_PASS"

        # clean up any leftover state
        rm -rf _work externals .credentials .agent
        
    fi
  fi

}

# https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agent-authentication-options?view=azure-devops
# https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/personal-access-token-agent-registration?view=azure-devops&source=recommendations

# pat - Personal Access Token
# alt - Basic Authentication

cleanup();

echo ">> Configuring Azure DevOps Agent..."

if [ "${AZ_AUTH_TYPE:-}"=="pat" ]; then
    # Token Authentication
    ./config.sh --unattended \
    --url   "$AZ_URL" \
    --auth  "$AZ_AUTH_TYPE" \
    --token "$AZ_TOKEN" \
    --pool  "$AZ_POOL" \
    --agent "$AZ_AGENT_NAME" \
    --acceptTeeEula
else
    # Username and password authentication
    ./config.sh --unattended \
    --url   "$AZ_URL" \
    --auth  "$AZ_AUTH_TYPE" \
    --user  "$AZ_USER" \
    --password "$AZ_PASS" \
    --pool  "$AZ_POOL" \
    --agent "$AZ_AGENT_NAME" \
    --acceptTeeEula
fi

# Graceful cleanup on termination signals
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

echo ">> Azure DevOps Agent startup"
echo "   URL:   $AZ_URL"
echo "   Pool:  $AZ_POOL"
echo "   Agent: $AZ_AGENT_NAME"
echo "   Auth Type: $AZ_AUTH_TYPE"
exec ./run.sh
#!/bin/bash
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "${0}")")"

# include shell script function definitions
source ./includes/include_client_resources.sh

# initialize the deployment script
initialize_deployment_script "${DEPLOYMENT_SCRIPT_LOGS}" "${0}"

# prepare and execute the deployment script
time client_deploy_database "${1:-}" "${2:-}" "${3:-}"

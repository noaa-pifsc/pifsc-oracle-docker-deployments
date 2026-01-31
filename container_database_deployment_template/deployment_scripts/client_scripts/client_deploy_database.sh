#!/bin/bash
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# prepare and execute the deployment script
time client_deploy_database "${0}" "${1:-}" "${2:-}" "${3:-}"

#!/bin/bash
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# deploy the container based on the arguments specified by the user 
# $1: (optional) the environment name (dev, test, prod)
# $2: (optional) deployment destination (local, server)
# $3: (optional) container_build_image (yes = the container image is built and then run, no = the container is restarted using the existing container image)
# $4: (optional) container_script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6)

# declare the function arguments
declare -A FUNC_ARGS=(
		["calling_script_path"]="${0}"
		["container_env_name"]="${1:-}"
		["container_deploy_dest"]="${2:-}"
		["container_script_type"]="${3:-}"
	)

# prepare and execute the deployment script
time client_deploy_database "FUNC_ARGS"

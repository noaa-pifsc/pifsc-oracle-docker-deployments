#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# main function that executes the database deployment based on the arguments specified by the user 
# $0: full path of the script that was executed directly
# $1: (optional) the environment name (dev, test, prod)
# $2: (optional) deployment destination (local, server)
# $3: (optional) container_script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6)
function main ()
{
	# declare the function arguments as a local variable
	local -A func_args=(
			["calling_script_path"]="${0}"
			["container_env_name"]="${1:-}"
			["container_deploy_dest"]="${2:-}"
			["container_script_type"]="${3:-}"
		)

	# prepare and execute the deployment script
	time proj_client_deploy_database "func_args"
}

# execute the main function with all arguments from this calling script:
main "$@"
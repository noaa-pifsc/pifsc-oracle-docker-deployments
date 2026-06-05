#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# main function that executes the database deployment based on the arguments specified by the user 
# $1: (optional) the environment name (dev, test, prod)
# $2: (optional) deployment destination (local, server)
# $3: (optional) container_script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6)
function main ()
{
	# notify the user which script is being run
	echo ""
	echo "**********************************************************************"
	echo "*********** Executing container database deployment script ***********"
	echo "**********************************************************************"
	echo ""
	echo "*Note: This script will deploy the specified database to the specified destination"
	echo ""

	# declare the function arguments as a local variable
	local -A func_args=(
			["env_name"]="${1:-}"
			["deploy_dest"]="${2:-}"
			["container_script_type"]="${3:-}"
		)

	# prepare and execute the deployment script
	time proj_client_deploy_database "func_args"
}

# execute the main function with all arguments from this calling script:
main "$@"
#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_database.sh:
# this host script runs a script as the $CONTAINER_ACCOUNT_NAME to build the 
# container image and run the container on the container host by executing 
# host_deploy_database_elev_privs.sh
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# main function to execute the container database deployment script on the container host:
function main ()
{
	# declare the function arguments as a local variable
	local -A func_args=(
			["container_account_name"]="${CONTAINER_ACCOUNT_NAME}" 
			["container_host_source_path"]="${CONTAINER_HOST_PROJECT_PATH}"
			["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
			["deploy_script_path"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/host_deploy_database_elev_privs.sh"
			["env_vars_block"]="$(proj_shared_define_env_vars_block)"
			["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
			["calling_script_path"]="${0}"
			["cds_host_process_stdin_config_data"]="yes"
		)

	echo "calling cds_host_deploy_container()"
	
	# initialize and build/run the container on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"
}

# execute the main function with the full script path for this calling script:
main "$@"
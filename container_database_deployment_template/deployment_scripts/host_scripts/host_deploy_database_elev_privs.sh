#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_database_elev_privs.sh:
# this host script runs as the $CONTAINER_ACCOUNT_NAME to build and run 
# the container and execute a specified script from within the container
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# main function to execute the container database deployment using elevated privileges:
function main()
{
	# declare the function arguments as a local variable
	local -A func_args=(
			["env_vars_block"]="$(proj_shared_define_env_vars_block "${CONTAINER_ENV_NAME}" "${CONTAINER_SCRIPT_TYPE}")"
			["container_scripts_path"]="${CONTAINER_SCRIPTS_PATH}"\
			["calling_script_path"]="${0}"
			["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
			["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
			["container_compose_file_path"]="${CONTAINER_COMPOSE_FILE_PATH}"
			["container_host_source_path"]="${CONTAINER_HOST_SOURCE_PATH}"
			["container_name"]="${COMPOSE_PROJECT_NAME}"
			["container_build_path"]="${CONTAINER_BUILD_PATH}"
			["container_script_type"]="${CONTAINER_SCRIPT_TYPE}"
		)

#	echo "calling cdd_host_deploy_database_execute_container_script() with the function arguments: $(cds_shared_dump_array_vals "func_args")"
	
	# execute the scripts from within the container with the specified function arguments:
	cdd_host_deploy_database_execute_container_script "func_args" 
}

# execute the main function with the full script path for this calling script:
main "$@"
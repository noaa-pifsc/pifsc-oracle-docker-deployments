#!/bin/bash

#-----------------------------------------------------------------------------
# host_deploy_database.sh:
# this host script runs a script as the $CONTAINER_ACCOUNT_NAME to build the 
# container image and run the container on the container host by executing 
# host_deploy_database_elev_privs.sh
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# declare the function arguments
declare -A FUNC_ARGS=(
		["container_account_name"]="${CONTAINER_ACCOUNT_NAME}" 
		["container_host_source_path"]="${CONTAINER_HOST_PROJECT_PATH}"
		["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
		["deploy_script_path"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/host_deploy_database_elev_privs.sh"
		["env_vars_block"]="$(define_env_vars_block)"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		["calling_script_path"]="${0}"
		["process_stdin_config_data"]="yes"
	)

# initialize and build/run the container on the host machine with the specified function arguments:
host_deploy_container "FUNC_ARGS"
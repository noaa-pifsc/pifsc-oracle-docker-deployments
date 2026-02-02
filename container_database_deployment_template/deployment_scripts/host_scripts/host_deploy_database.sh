#!/bin/bash

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# declare the function arguments
declare -A FUNC_ARGS=(
		["current_script_name"]="${0}"
		["parent_root_folder"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
		["container_host_project_path"]="${CONTAINER_HOST_PROJECT_PATH}"
		["container_account_name"]="${CONTAINER_ACCOUNT_NAME}" 
		["container_host_scripts_path"]="${CONTAINER_HOST_SCRIPTS_PATH}"
		["host_script_name"]="host_deploy_database_elev_privs.sh"
		["env_vars_block"]="$(define_env_vars_block)"
	)

# initialize and build/run the container on the host machine with the specified function arguments:
host_deploy_container "FUNC_ARGS"
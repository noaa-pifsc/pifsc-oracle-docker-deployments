#!/bin/bash

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# declare the function arguments
declare -A FUNC_ARGS=(
		["env_vars_block"]="$(define_env_vars_block)"
		["container_scripts_path"]="${CONTAINER_SCRIPTS_PATH}"
		["calling_script_path"]="${0}"
		["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		["container_compose_file_path"]="${CONTAINER_COMPOSE_FILE_PATH}"
		["container_host_source_path"]="${CONTAINER_HOST_SOURCE_PATH}"
	)

# execute the scripts from within the container with the specified function arguments:
host_deploy_database_execute_container_script "FUNC_ARGS" 

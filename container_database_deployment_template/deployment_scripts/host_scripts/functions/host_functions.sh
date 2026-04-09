#!/bin/bash

# function that begins the container deployment process on a given container host with an unprivileged account
# This function accepts no parameters
function proj_host_deploy_container()
{
	if ! cds_shared_validate_required_vars "PRIV_USER" "HOST_SOURCE_PATH" "SECRET_DATA_VAR_NAME" "ENV_NAME" "SCRIPT_TYPE" "SECRET_MAPPING_VAR_NAME"; then 
        echo "Error: proj_host_deploy_container() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments as a local variable
	local -A func_args=(
			["target_user"]="${PRIV_USER}" 
			["source_path"]="${HOST_SOURCE_PATH}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["deploy_script_path"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../host_deploy_database_elev_privs.sh"
			["env_block"]="$(proj_shared_define_env_vars_block "${ENV_NAME}" "${SCRIPT_TYPE}")"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="yes"
		)

	# initialize and build/run the container on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"	
}

# function that executes the container deployment process on a given container host with a privileged account
# This function accepts no parameters
function proj_host_deploy_container_elev_privs()
{
	if ! cds_shared_validate_required_vars "ENV_NAME" "SCRIPT_TYPE" "CONTAINER_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME" "COMPOSE_PATH" "SOURCE_PATH" "CONTAINER_NAME" "BUILD_PATH" ; then 
        echo "Error: proj_host_deploy_container_elev_privs() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments as a local variable
	local -A func_args=(
			["env_block"]="$(proj_shared_define_env_vars_block "${ENV_NAME}" "${SCRIPT_TYPE}")"
			["scripts_path"]="${CONTAINER_SCRIPTS_PATH}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["compose_path"]="${COMPOSE_PATH}"
			["source_path"]="${SOURCE_PATH}"
			["container_name"]="${CONTAINER_NAME}"
			["build_path"]="${BUILD_PATH}"
			["container_script_type"]="${SCRIPT_TYPE}"
			["image_name"]="${IMAGE_NAME}"
		)

	# execute the scripts from within the container with the specified function arguments:
	cdd_host_deploy_database_execute_container_script "func_args" 
}
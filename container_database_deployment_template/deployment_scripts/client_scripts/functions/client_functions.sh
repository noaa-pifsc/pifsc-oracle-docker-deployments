#!/bin/bash

# function that initializes the CONTAINER_ENV_NAME variable and loads the client secret/configuration files, and process the $config_data_var_name so it can be passed to a bash script via STDIN
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# calling_script_path: the full path of the calling script
# container_env_name: (optional) the environment name (dev, test, prod)
# container_deploy_dest: (optional) deployment destination (local, server)
# script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
function client_deploy_database ()
{
	echo "deploy the database from the client script"

	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: client_deploy_database() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "calling_script_path"; then 
        echo "ERROR: client_deploy_database() function argument validation failed" >&2
        return 1
    fi

	# validate the bash variable values
	if ! validate_required_vars	"DEPLOYMENT_SCRIPT_LOGS" "CONTAINER_SCRIPTS_PATH" "CONTAINER_COMPOSE_FILE_PATH" "CONTAINER_HOST_PROJECT_PATH" "CONTAINER_GIT_URL" "CONFIG_DATA_VAR_NAME" "CONTAINER_HOST_SCRIPTS_PATH" "LOCAL_CONTAINER_BUILD_PATH" "SECRET_MAPPING_VAR_NAME" "REPO_ROOT_PATH"; then
        echo "ERROR: client_deploy_database() function required bash variable validation failed" >&2
        return 1
	fi

	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# process the runtime arguments
	client_process_runtime_arguments "${DEPLOYMENT_SCRIPT_LOGS}" "$(get_array_val "${arg_array}" "calling_script_path")" "$(get_array_val "${arg_array}" "container_env_name")" "$(get_array_val "${arg_array}" "container_deploy_dest")" "$(get_array_val "${arg_array}" "script_type")"

	# validate that the corresponding container script exists:
	if [ ! -f "${curr_dir}/../../container_scripts/container_${SCRIPT_TYPE}.sh" ]; then
		echo "ERROR: the script type definition (script type: ${SCRIPT_TYPE}) argument's corresponding container deployment file does not exist: $curr_dir/../../container_scripts/container_${SCRIPT_TYPE}.sh"
		return 1
	fi

	# load the client secrets and server configuration files
	client_load_config_files

	# declare the function arguments
	local -A LOCAL_CLIENT_DEPLOY_DATABASE_FUNC_ARGS=(
			["parent_root_folder"]="${REPO_ROOT_PATH}"
			["container_deploy_dest"]="${CONTAINER_DEPLOY_DEST}"
			["container_hostname"]="${CONTAINER_HOSTNAME}"
			["env_vars_block"]="$(define_env_vars_block)"
			["container_scripts_path"]="${CONTAINER_SCRIPTS_PATH}"
			["container_compose_file_path"]="${CONTAINER_COMPOSE_FILE_PATH}"
			["container_host_project_path"]="${CONTAINER_HOST_PROJECT_PATH}"
			["container_git_url"]="${CONTAINER_GIT_URL}"
			["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
			["container_host_scripts_path"]="${CONTAINER_HOST_SCRIPTS_PATH}"
			["local_container_build_path"]="${LOCAL_CONTAINER_BUILD_PATH}"
			["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
			["ssh_env_vars"]="$(client_generate_ssh_env_vars)"
		)

	# prepare and execute the corresponding deployment script:
	client_execute_deploy_database "LOCAL_CLIENT_DEPLOY_DATABASE_FUNC_ARGS"
}

# function to load the client configuration files (secrets and environment server configuration)
function client_load_config_files()
{
	# validate the bash variable values
	if ! validate_required_vars	"CONTAINER_ENV_NAME"; then
        echo "ERROR: client_load_config_files() function required bash variable validation failed" >&2
        return 1
	fi

	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# load the bash variables for the runtime configuration (/container_database_deployment/deployment_scripts/config)
	source "${curr_dir}/../../config/deploy_config.${CONTAINER_ENV_NAME}.sh"
	
	# load the oracle credentials into bash variables (/container_database_deployment/secrets/$CONTAINER_ENV_NAME)
	source "${curr_dir}/../../../secrets/${CONTAINER_ENV_NAME}/secrets.sh"
}
#!/bin/bash

# function that initializes the CONTAINER_ENV_NAME variable and loads the client secret/configuration files, and process the $config_data_var_name so it can be passed to a bash script via STDIN
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# calling_script_path: the full path of the calling script
# container_env_name: (optional) the environment name (dev, test, prod)
# container_deploy_dest: (optional) deployment destination (local, server)
# container_script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
function proj_client_deploy_database ()
{
	echo "deploy the database from the client script"

	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: proj_client_deploy_database() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "calling_script_path"; then 
        echo "Error: proj_client_deploy_database() function argument validation failed" >&2
        return 1
    fi

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"DEPLOYMENT_SCRIPT_LOGS" "CONTAINER_SCRIPTS_PATH" "CONTAINER_COMPOSE_FILE_PATH" "CONTAINER_HOST_PROJECT_PATH" "CONTAINER_GIT_URL" "CONFIG_DATA_VAR_NAME" "CONTAINER_HOST_SCRIPTS_PATH" "CONTAINER_BUILD_PATH" "SECRET_MAPPING_VAR_NAME" "REPO_ROOT_PATH" "PROJECT_CONTAINER_NAME" "LOCAL_CONTAINER_SCRIPTS_PATH"; then
        echo "Error: proj_client_deploy_database() function required bash variable validation failed" >&2
        return 1
	fi

	# declare the function arguments for cdd_client_process_runtime_arguments()
	local -A local_runtime_args=(
			["script_log_path"]="${DEPLOYMENT_SCRIPT_LOGS}"
			["calling_script_path"]="$(cds_shared_get_array_val "${arg_array}" "calling_script_path")"
			["container_env_name"]="$(cds_shared_get_array_val "${arg_array}" "container_env_name")"
			["container_deploy_dest"]="$(cds_shared_get_array_val "${arg_array}" "container_deploy_dest")"
			["container_script_type"]="$(cds_shared_get_array_val "${arg_array}" "container_script_type")"
			["client_repository_root_path"]="${REPO_ROOT_PATH}"
			["container_script_path"]="${LOCAL_CONTAINER_SCRIPTS_PATH}"
		)

	# process the runtime arguments
	cdd_client_process_runtime_arguments "local_runtime_args"

	# load the client secrets and server configuration files
	proj_client_load_secrets

	# declare the function arguments
	local -A deploy_args=(
			["parent_root_folder"]="${REPO_ROOT_PATH}"
			["container_deploy_dest"]="${CONTAINER_DEPLOY_DEST}"
			["container_hostname"]="${CONTAINER_HOSTNAME}"
			["env_vars_block"]="$(proj_shared_define_env_vars_block)"
			["container_scripts_path"]="${CONTAINER_SCRIPTS_PATH}"
			["container_compose_file_path"]="${CONTAINER_COMPOSE_FILE_PATH}"
			["container_host_project_path"]="${CONTAINER_HOST_PROJECT_PATH}"
			["container_git_url"]="${CONTAINER_GIT_URL}"
			["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
			["container_host_scripts_path"]="${CONTAINER_HOST_SCRIPTS_PATH}"
			["container_build_path"]="${CONTAINER_BUILD_PATH}"
			["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
			["ssh_env_vars"]="$(proj_client_generate_ssh_env_vars)"
			["container_name"]="${PROJECT_CONTAINER_NAME}"
		)

	# prepare and execute the corresponding deployment script:
	cdd_client_execute_deploy_database "deploy_args"
}

# function to load the client configuration files (secrets and environment server configuration)
# the function accepts one argument:
# 1: The container environment name (dev, test, prod)
function proj_client_load_secrets()
{
	local $local_env_name="${1}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"local_env_name"; then
        echo "Error: proj_client_load_secrets() function required bash variable validation failed" >&2
        return 1
	fi

	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# load the bash variables for the runtime configuration (/container_database_deployment/deployment_scripts/config)
	source "${curr_dir}/../../config/deploy_config.${local_env_name}.sh"
	
	# load the oracle credentials into bash variables (/container_database_deployment/secrets/$local_env_name)
	source "${curr_dir}/../../../secrets/${local_env_name}/secrets.sh"
}
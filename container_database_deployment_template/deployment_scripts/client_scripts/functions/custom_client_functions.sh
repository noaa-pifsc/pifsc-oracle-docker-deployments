#!/bin/bash

# function that initializes the ENV_NAME variable and loads the client secret/configuration files, and process the $config_data_var_name so it can be passed to a bash script via STDIN
# this function accepts the following parameters: 
# 1: current_script_name: the full path of the calling script
# 2: (optional) the environment name (dev, test, prod)
# 3: (optional) deployment destination (local, server)
# 4: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
function client_deploy_database ()
{
	echo "deploy the database from the client script"

	local current_script_name="${1}"
	local env_name="${2}"
	local deploy_dest="${3}"
	local script_type="${4}"

	if [ -z "${current_script_name}" ]; then
		echo "ERROR: for client_deploy_database() the current script name parameter is required"
		return 1
	fi

	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# process the runtime arguments
	client_process_runtime_arguments "${curr_dir}/../../../deployment_script_logs" "${current_script_name}" "${env_name}" "${deploy_dest}" "${script_type}"

	# validate that the corresponding container script exists:
	if [ ! -f "${curr_dir}/../../container_scripts/container_${SCRIPT_TYPE}.sh" ]; then
		echo "ERROR: the script type definition (script type: ${SCRIPT_TYPE}) argument's corresponding container deployment file does not exist: $curr_dir/../../container_scripts/container_${SCRIPT_TYPE}.sh"
		return 1
	fi

	# load the client secrets and server configuration files
	client_load_config_files

	# declare the function arguments
	declare -A FUNC_ARGS=(
			["parent_root_folder"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../../"
			["env_name"]="${ENV_NAME}"
			["deploy_dest"]="${DEPLOY_DEST}"
			["container_hostname"]="${CONTAINER_HOSTNAME}"
			["env_vars_block"]="$(host_deploy_define_env_vars_block)"
			["container_scripts_path"]="${CONTAINER_SCRIPTS_PATH}"
			["container_compose_file_path"]="${CONTAINER_COMPOSE_FILE_PATH}"
			["container_host_project_path"]="${CONTAINER_HOST_PROJECT_PATH}"
			["container_git_url"]="${CONTAINER_GIT_URL}"
			["config_data_var_name"]="${CONFIG_DATA_VAR_NAME}"
			["container_host_scripts_path"]="${CONTAINER_HOST_SCRIPTS_PATH}"
			["local_container_build_path"]="${LOCAL_CONTAINER_BUILD_PATH}"
			["script_type"]="${SCRIPT_TYPE}"
			["db_host"]="${DB_HOST}"
			["db_service_name"]="${DB_SERVICE_NAME}"
			["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		)

	# prepare and execute the corresponding deployment script:
	client_execute_deploy_database "FUNC_ARGS"
}

# function to load the client configuration files (secrets and environment server configuration)
function client_load_config_files()
{
	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# load the bash variables for the runtime configuration (/container_database_deployment/deployment_scripts/config)
	source "${curr_dir}/../../config/deploy_config.${ENV_NAME}.sh"
	
	# load the oracle credentials into bash variables (/container_database_deployment/secrets/$ENV_NAME)
	source "${curr_dir}/../../../secrets/${ENV_NAME}/secrets.sh"
}
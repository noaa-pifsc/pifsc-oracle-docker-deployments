#!/bin/bash

# function that initializes the env_name variable and loads the client secret/configuration files, and process the $secret_var so it can be passed to a bash script via STDIN
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# env_name: (optional) the environment name (dev, test, prod)
# deploy_dest: (optional) deployment destination (local, server)
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

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"DEPLOYMENT_SCRIPT_LOGS" "CONTAINER_SCRIPTS_PATH" "COMPOSE_PATH" "HOST_SOURCE_PATH" "GIT_URL" "SECRET_DATA_VAR_NAME" "HOST_SCRIPTS_PATH" "BUILD_PATH" "SECRET_MAPPING_VAR_NAME" "REPO_ROOT_PATH" "CONTAINER_NAME" "LOCAL_CONTAINER_SCRIPTS_PATH"; then
        echo "Error: proj_client_deploy_database() function required bash variable validation failed" >&2
        return 1
	fi
	
	# declare the function arguments for cdd_client_process_runtime_arguments()
	local -A local_runtime_args=(
			["log_path"]="${DEPLOYMENT_SCRIPT_LOGS}"
			["env_name"]="$(cds_shared_get_array_val "${arg_array}" "env_name")"
			["deploy_dest"]="$(cds_shared_get_array_val "${arg_array}" "deploy_dest")"
			["container_script_type"]="$(cds_shared_get_array_val "${arg_array}" "container_script_type")"
			["repo_root"]="${REPO_ROOT_PATH}"
			["scripts_path"]="${LOCAL_CONTAINER_SCRIPTS_PATH}"
		)

	# process the runtime arguments
	cdd_client_process_runtime_arguments "local_runtime_args"

	# load the client secrets and server configuration files
	proj_client_load_secrets "$(cds_shared_get_array_val "local_runtime_args" "env_name")"

	# declare the function arguments
	local -A deploy_args=(
			["parent_root_folder"]="${REPO_ROOT_PATH}"
			["deploy_dest"]="$(cds_shared_get_array_val "local_runtime_args" "deploy_dest")"
			["target_host"]="${CONTAINER_HOSTNAME}"
			["env_block"]="$(proj_shared_define_env_vars_block "$(cds_shared_get_array_val "local_runtime_args" "env_name")" "$(cds_shared_get_array_val "local_runtime_args" "container_script_type")")"
			["scripts_path"]="${CONTAINER_SCRIPTS_PATH}"
			["compose_path"]="${COMPOSE_PATH}"
			["source_path"]="${HOST_SOURCE_PATH}"
			["git_url"]="${GIT_URL}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["host_scripts_path"]="${HOST_SCRIPTS_PATH}"
			["build_path"]="${BUILD_PATH}"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["ssh_env_vars"]="$(proj_client_generate_ssh_env_vars "$(cds_shared_get_array_val "local_runtime_args" "env_name")" "$(cds_shared_get_array_val "local_runtime_args" "container_script_type")")"
			["container_name"]="${CONTAINER_NAME}"
			["container_script_type"]="$(cds_shared_get_array_val "local_runtime_args" "container_script_type")"
			["image_name"]="${IMAGE_NAME}"
		)

	# prepare and execute the corresponding deployment script:
	cdd_client_execute_deploy_database "deploy_args"
}

# function to load the client configuration files (secrets and environment server configuration)
# the function accepts 1 parameter: the environment name (e.g. dev, test, prod)
function proj_client_load_secrets()
{
	local env_name="${1}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"env_name"; then
        echo "Error: proj_client_load_secrets() function required bash variable validation failed" >&2
        return 1
	fi

	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# load the bash variables for the runtime configuration (/container_database_deployment/deployment_scripts/config)
	source "${curr_dir}/../../config/deploy_config.${env_name}.sh"
	
	# load the database credentials into bash variables (/container_database_deployment/secrets/$env_name)
	source "${curr_dir}/../../../secrets/${env_name}/secrets.sh"
}

# function to define the ssh environment variables for the database deployment server bash script
# Accepts 2 parameters: 
# 1: the environment name
# 2: the script type
function proj_client_generate_ssh_env_vars ()
{
	local env_name="${1}"
	local script_type="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"env_name" "script_type"; then
        echo "Error: proj_client_generate_ssh_env_vars() function required bash variable validation failed" >&2
        return 1
	fi
	
	# echo the local values natively and use the dynamic generatr for the global configuration constants (DB_HOST, DB_SERVICE_NAME)
	echo "ENV_NAME=\"${env_name}\" SCRIPT_TYPE=\"${script_type}\" $(cds_shared_generate_ssh_env_vars_string "DB_HOST" "DB_SERVICE_NAME")"
}
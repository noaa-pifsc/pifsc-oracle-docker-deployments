#!/bin/bash

# this function initializes the SCRIPT_TYPE variable for use in the script.
# this function accepts an optional parameter: the script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# Example Usage:  
#   set_script_type_var "$1"
#   or with no arguments to trigger prompts:
#   set_script_type_var
function set_script_type_var ()
{
    # Calls the helper with its specific parameters
    set_validated_var \
        "SCRIPT_TYPE" \
        "Enter destination (name of the database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "[a-zA-Z0-9_\.]+" \
        "the name of container script with the naming convention container_[SCRIPT_TYPE].sh" \
        "${1}"
}

# function that initializes the client deployment script and processes the client runtime arguments and prompts for any missing values
# this function accepts the following runtime arguments:
# 1: deployment script logs path
# 2: calling script path
# 3: (optional) ENV_NAME
# 4: (optional) DEPLOY_DEST
# 5: (optional) SCRIPT_TYPE
function client_process_runtime_arguments ()
{
	echo "process client runtime arguments"

	local script_log_path="${1}"
	local current_script_name="${2}"
	local env_name="${3}"
	local deploy_dest="${4}"
	local script_type="${5}"

	# input validation
    if [[ -z "${script_log_path}" || -z "${current_script_name}" ]]; then
        echo "ERROR: client_process_runtime_arguments() requires the deployment script logs path and calling script path as arguments" >&2
        return 1
    fi

	# initialize the deployment script
	initialize_deployment_script "${script_log_path}" "${current_script_name}"

	# set the environment and deployment destination variable values
	set_env_deployment_vars "${env_name}" "${deploy_dest}"
	
	# set the script type variable value
	set_script_type_var "${script_type}"
}


# this function prepares and executes the client deployment scripts
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# env_name: (optional) the environment name (dev, test, prod)
# deploy_dest: (optional) deployment destination (local, server)
# container_hostname: container hostname to connect to
# container_host_project_path: the container source directory on the container host
# container_git_url: git url for the container project's repository
# config_data_var_name: name of the configuration data variable
# container_host_scripts_path: the path to the folder where the host bash scripts are contained
# local_container_build_path: the local container build folder path (/container_database_deployment)
# container_compose_file_path: the path of the container compose file (relative to the container build folder path)
# script_type: the script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# db_host: the database hostname
# db_service_name: the database service name
# secret_mapping_var_name: the name of the associative array containing the secret names and corresponding bash variables
# container_scripts_path: the path to the container's bash scripts folder
# parent_root_folder: the repository root folder (used to convert all .sh files to use linux-style line endings for compatibility purposes)
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# Example Usage:
#   client_execute_deploy_database "FUNC_ARGS"
function client_execute_deploy_database ()
{
	echo "prepare the container source files and deploy the container"
	
	# store the function array argument
	local arg_array="${1}"

	# input validation
    if [[ -z "$(get_array_val "${arg_array}" "parent_root_folder")" || -z "$(get_array_val "${arg_array}" "env_name")" || -z "$(get_array_val "${arg_array}" "deployment_destination")" || -z "$(get_array_val "${arg_array}" "container_hostname")" || -z "$(get_array_val "${arg_array}" "container_host_project_path")" || -z "$(get_array_val "${arg_array}" "container_git_url")" || -z "$(get_array_val "${arg_array}" "config_data_var_name")" || -z "$(get_array_val "${arg_array}" "container_host_scripts_path")" || -z "$(get_array_val "${arg_array}" "local_container_build_path")" || -z "$(get_array_val "${arg_array}" "container_compose_file_path")" || -z "$(get_array_val "${arg_array}" "script_type")" || -z "$(get_array_val "${arg_array}" "db_host")" || -z "$(get_array_val "${arg_array}" "db_service_name")" || -z "$(get_array_val "${arg_array}" "secret_mapping_var_name")" || -z "$(get_array_val "${arg_array}" "container_scripts_path")" ]]; then
        echo "ERROR: client_execute_deploy_database() requires the environment name, the deployment destination, the container hostname to connect to, the container source directory on the container host, git url for the container project's repository, name of the configuration data variable, the path to the folder where the host bash scripts are contained, the local container build folder path (/container_database_deployment), the path of the container compose file (relative to the container build folder path), the script type, the database host, the database service name, the name of an associative array that maps the secret values passed to bash commands via STDIN, the path to the container's bash scripts folder, and the repository root folder as arguments" >&2
        return 1
    fi

	local config_data_var_name="$(get_array_val "${arg_array}" "config_data_var_name")"

	# recursively convert the line endings for all .sh files in the root folder of the repository (/)
	convert_dos2unix "$(get_array_val "${arg_array}" "parent_root_folder")"

	# process the configuration data
	process_config_data "$(get_array_val "${arg_array}" "secret_mapping_var_name")" "$(get_array_val "${arg_array}" "config_data_var_name")"


	# Check if the DEPLOY_DEST variable is "server" 
	if [[ "$(get_array_val "${arg_array}" "deploy_dest")" == "server" ]]; then
		# Prepare the container host by cloning the project repository
		prepare_container_host "$(get_array_val "${arg_array}" "container_hostname")" "$(get_array_val "${arg_array}" "container_host_project_path")" "$(get_array_val "${arg_array}" "container_git_url")"

		# execute the container deployment script on the host server and specify the sensitive values as stdin and the configuration values as environment variables
		exec_remote_cmd_with_stdin "$(get_array_val "${arg_array}" "container_hostname")" "${!config_data_var_name}" "SCRIPT_TYPE=\"$(get_array_val "${arg_array}" "script_type")\" DB_HOST=\"$(get_array_val "${arg_array}" "db_host")\" DB_SERVICE_NAME=\"$(get_array_val "${arg_array}" "db_service_name")\" ENV_NAME=\"$(get_array_val "${arg_array}" "env_name")\" bash $(get_array_val "${arg_array}" "container_host_scripts_path")/host_deploy_database.sh"

		# unset the configuration now that the ssh call has completed
		unset_config_data "$(get_array_val "${arg_array}" "config_data_var_name")"

	else
		# this is a local deployment scenario:
		
		# change directory into the container folder that contains the Dockerfile and .yml files (/container_database_deployment)
		cd "$(get_array_val "${arg_array}" "local_container_build_path")"

		# this is a mounted directory deployment
		echo "deploy the container with container compose for development purposes"

		# stop and remove any running container and build/run the container from the source code
		build_deploy_container "$(get_array_val "${arg_array}" "container_compose_file_path")"

		# execute the corresponding container scripts and shutdown the container
		host_execute_container_script "$(get_array_val "${arg_array}" "container_scripts_path")" "$(get_array_val "${arg_array}" "container_compose_file_path")" "$(get_array_val "${arg_array}" "config_data_var_name")"  "$(get_array_val "${arg_array}" "env_vars_block")"

		echo "the local container deployment script has finished executing"

	fi
}

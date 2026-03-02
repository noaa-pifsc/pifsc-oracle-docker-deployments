#!/bin/bash

# this function initializes the CONTAINER_SCRIPT_TYPE variable for use in the script.
# this function accepts an optional parameter: the script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# Example Usage:  
#   set_container_script_type_var "$1"
#   or with no arguments to trigger prompts:
#   set_container_script_type_var
function set_container_script_type_var ()
{
    # Calls the helper with its specific parameters
    set_validated_var \
        "CONTAINER_SCRIPT_TYPE" \
        "Enter destination (name of the database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "[a-zA-Z0-9_\.]+" \
        "the name of container script with the naming convention container_[CONTAINER_SCRIPT_TYPE].sh" \
        "${1}"
}

# function that initializes the client deployment script and processes the client runtime arguments and prompts for any missing values
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# calling_script_path: the full path of the calling script
# script_log_path: the full path to the folder that deployment logs will be saved to
# container_env_name: (optional) the environment name (dev, test, prod)
# container_deploy_dest: (optional) deployment destination (local, server)
# container_script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# client_repository_root_path: the client repository root path that will have dos2unix executed for it to ensure linux compatible line endings
# container_script_path: the script path for the container scripts
function client_process_runtime_arguments ()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: client_process_runtime_arguments() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "calling_script_path" "script_log_path" "client_repository_root_path" "container_script_path"; then 
        echo "ERROR: client_process_runtime_arguments() function argument validation failed" >&2
        return 1
    fi

	# initialize the deployment script
	initialize_deployment_script "$(get_array_val "${arg_array}" "script_log_path")" "$(get_array_val "${arg_array}" "calling_script_path")" 

	# set the environment and deployment destination variable values
	set_env_deployment_vars "$(get_array_val "${arg_array}" "container_env_name")" "$(get_array_val "${arg_array}" "container_deploy_dest")"
	
	# set the script type variable value
	set_container_script_type_var "$(get_array_val "${arg_array}" "container_script_type")"

	# recursively convert the line endings for all .sh files in the root folder of the repository (/)
	convert_dos2unix "$(get_array_val "${arg_array}" "client_repository_root_path")"

	# validate that the corresponding container script exists:
	if [ ! -f "$(get_array_val "${arg_array}" "container_script_path")/container_${CONTAINER_SCRIPT_TYPE}.sh" ]; then
		echo "ERROR: the script type definition (script type: ${CONTAINER_SCRIPT_TYPE}) argument's corresponding container deployment file does not exist: $(get_array_val "${arg_array}" "container_script_path")/container_${CONTAINER_SCRIPT_TYPE}.sh"
		return 1
	fi

}


# this function prepares and executes the client deployment scripts
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# container_deploy_dest: deployment destination (local, server)
# ssh_env_vars: the ssh environment variables that are passed to the server bash script call
# container_hostname: container hostname to connect to
# container_host_project_path: the container source directory on the container host
# container_git_url: git url for the container project's repository
# config_data_var_name: name of the configuration data variable
# container_host_scripts_path: the path to the folder where the host bash scripts are contained
# local_container_build_path: the local container build folder path (/container_database_deployment)
# container_compose_file_path: the path of the container compose file (relative to the container build folder path)
# secret_mapping_var_name: the name of the associative array containing the secret names and corresponding bash variables
# container_scripts_path: the path to the container's bash scripts folder
# parent_root_folder: the repository root folder (used to convert all .sh files to use linux-style line endings for compatibility purposes)
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# Example Usage:
#   client_execute_deploy_database "FUNC_ARGS"
function client_execute_deploy_database ()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: client_execute_deploy_database() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "parent_root_folder" "ssh_env_vars" "container_deploy_dest" "container_hostname" "container_host_project_path" "container_git_url" "config_data_var_name" "container_host_scripts_path" "local_container_build_path" "container_compose_file_path" "secret_mapping_var_name" "container_scripts_path" "container_name"; then 
        echo "ERROR: client_execute_deploy_database() function argument validation failed" >&2
        return 1
    fi

	local config_data_var_name="$(get_array_val "${arg_array}" "config_data_var_name")"

	# process the configuration data
	process_config_data "$(get_array_val "${arg_array}" "secret_mapping_var_name")" "$(get_array_val "${arg_array}" "config_data_var_name")"

	# Check if the CONTAINER_DEPLOY_DEST variable is "server" 
	if [[ "$(get_array_val "${arg_array}" "container_deploy_dest")" == "server" ]]; then

		# this is a server deployment
		echo "deploy the database deployment container to the server"

		# Prepare the container host by cloning the project repository
		prepare_container_host "$(get_array_val "${arg_array}" "container_hostname")" "$(get_array_val "${arg_array}" "container_host_project_path")" "$(get_array_val "${arg_array}" "container_git_url")"

		# declare the function arguments
		local -A LOCAL_CLIENT_EXECUTE_DEPLOY_DATABASE_ARGS=(
				["container_hostname"]="$(get_array_val "${arg_array}" "container_hostname")"
				["passed_stdin_content"]="${!config_data_var_name}"
				["cmd"]="$(get_array_val "${arg_array}" "ssh_env_vars") bash $(get_array_val "${arg_array}" "container_host_scripts_path")/host_deploy_database.sh"
			)

		# execute the container deployment script on the host server and specify the sensitive values as stdin and the configuration values as environment variables
		exec_remote_cmd "LOCAL_CLIENT_EXECUTE_DEPLOY_DATABASE_ARGS"

	else
		# this is a local deployment scenario:
		
		# change directory into the container folder that contains the Dockerfile and .yml files (/container_database_deployment)
		cd "$(get_array_val "${arg_array}" "local_container_build_path")"

		# stop and remove any running container and build/run the container from the source code
		build_deploy_container_compose "$(get_array_val "${arg_array}" "container_compose_file_path")"

		# declare the function arguments
		local -A LOCAL_CLIENT_EXECUTE_DEPLOY_DATABASE_ARGS=(
				["container_scripts_path"]="$(get_array_val "${arg_array}" "container_scripts_path")"
				["container_compose_file_path"]="$(get_array_val "${arg_array}" "container_compose_file_path")"
				["config_data_var_name"]="$(get_array_val "${arg_array}" "config_data_var_name")"
				["env_vars_block"]="$(get_array_val "${arg_array}" "env_vars_block")"
				["container_name"]="$(get_array_val "${arg_array}" "container_name")"
			)

		# execute the corresponding container scripts and shutdown the container
		execute_container_script "LOCAL_CLIENT_EXECUTE_DEPLOY_DATABASE_ARGS"

		echo "the local container deployment script has finished executing"
	fi

	# unset the configuration now that the ssh call has completed
	unset_config_data "$(get_array_val "${arg_array}" "config_data_var_name")"
}

#!/bin/bash

# this function initializes a local variable that will contain the container script type value for use in the script.
# this function accepts the following parameters:
# 1: out_var_name (the name of the local variable where the validated script type value will be stored)
# 2: passed_value (optional: the script type value passed from the caller)
function cdd_set_container_script_type_var ()
{
    local out_var_name="${1}"
    local passed_value="${2:-}"

	# validate the bash variable values
	if ! cds_validate_required_vars	"out_var_name"; then
        echo "Error: cdd_set_container_script_type_var() function required function argument validation failed" >&2
        return 1
	fi
	
    # Calls the helper with its specific parameters
    cds_set_validated_var \
        "${out_var_name}" \
        "Enter destination (name of the database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "[a-zA-Z0-9_\.]+" \
        "the name of database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "${passed_value}"
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
function cdd_client_process_runtime_arguments ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_client_process_runtime_arguments() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_validate_required_array_vals "${arg_array}" "calling_script_path" "script_log_path" "client_repository_root_path" "container_script_path"; then 
        echo "Error: cdd_client_process_runtime_arguments() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments for cds_client_process_runtime_arguments()
	local -A local_client_process_runtime_arguments=(
			["script_log_path"]="$(cds_get_array_val "${arg_array}" "script_log_path")"
			["calling_script_path"]="$(cds_get_array_val "${arg_array}" "calling_script_path")"
			["container_env_name"]="$(cds_get_array_val "${arg_array}" "container_env_name")"
			["container_deploy_dest"]="$(cds_get_array_val "${arg_array}" "container_deploy_dest")"
			["client_repository_root_path"]="$(cds_get_array_val "${arg_array}" "client_repository_root_path")"
		)

	# process the runtime arguments
	cds_client_process_runtime_arguments "local_client_process_runtime_arguments"

	# set the script type variable value into a local variable
	local local_script_type=""
	cdd_set_container_script_type_var "${local_script_type}" "$(cds_get_array_val "${arg_array}" "container_script_type")"

	# Store the validated value back into the arguments array
	cds_set_array_val "${arg_array}" "container_script_type" "${local_script_type}"

	# validate that the corresponding container script exists:
	if [ ! -f "$(cds_get_array_val "${arg_array}" "container_script_path")/container_${local_script_type}.sh" ]; then
		echo "Error: the script type definition (script type: ${local_script_type}) argument's corresponding container deployment file does not exist: $(cds_get_array_val "${arg_array}" "container_script_path")/container_${local_script_type}.sh"
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
# container_build_path: the local container build folder path (/container_database_deployment)
# container_compose_file_path: the path of the container compose file (relative to the container build folder path)
# secret_mapping_var_name: the name of the associative array containing the secret names and corresponding bash variables
# container_scripts_path: the path to the container's bash scripts folder
# parent_root_folder: the repository root folder (used to convert all .sh files to use linux-style line endings for compatibility purposes)
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# Example Usage:
#   cdd_client_execute_deploy_database "FUNC_ARGS"
function cdd_client_execute_deploy_database ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_client_execute_deploy_database() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_validate_required_array_vals "${arg_array}" "parent_root_folder" "ssh_env_vars" "container_deploy_dest" "container_hostname" "container_host_project_path" "container_git_url" "config_data_var_name" "container_host_scripts_path" "container_build_path" "container_compose_file_path" "secret_mapping_var_name" "container_scripts_path" "container_name" "container_script_type"; then 
        echo "Error: cdd_client_execute_deploy_database() function argument validation failed" >&2
        return 1
    fi

	# Check if the CONTAINER_DEPLOY_DEST variable is "server" 
	if [[ "$(cds_get_array_val "${arg_array}" "container_deploy_dest")" == "server" ]]; then

		# this is a server deployment
		echo "deploy the database deployment container to the server"

		# declare the function arguments
		local -A remote_deploy_args=(
				["container_hostname"]="$(cds_get_array_val "${arg_array}" "container_hostname")"

				["container_host_project_path"]="$(cds_get_array_val "${arg_array}" "container_host_project_path")"
				["container_git_url"]="$(cds_get_array_val "${arg_array}" "container_git_url")"
				["remote_ssh_cmd"]="$(cds_get_array_val "${arg_array}" "ssh_env_vars") bash $(cds_get_array_val "${arg_array}" "container_host_scripts_path")/host_deploy_database.sh"

				["config_data_var_name"]="$(cds_get_array_val "${arg_array}" "config_data_var_name")"
				["secret_mapping_var_name"]="$(cds_get_array_val "${arg_array}" "secret_mapping_var_name")"
				["parse_config_data"]="yes"

			)
		
		cds_client_execute_remote_deployment "remote_deploy_args"

	else
		# this is a local deployment scenario:

		# construct the argument array for cds_build_deploy_container_compose()
		local -A local_build_deploy_container_compose_args=(
			["container_compose_file_path"]="$(cds_get_array_val "${arg_array}" "container_compose_file_path")"
			["container_build_image"]="yes"
			["container_build_path"]="$(cds_get_array_val "${arg_array}" "container_build_path")"
			["container_image_name"]="$(cds_get_array_val "${arg_array}" "container_name")"
			["export_secrets"]="no"
		)

		# stop and remove any running container and build/run the container from the source code
		cds_client_deploy_local_compose "local_build_deploy_container_compose_args"

		# process the configuration data to pass securely via STDIN and clear the floating global bash variables
		cds_process_config_data "$(cds_get_array_val "${arg_array}" "secret_mapping_var_name")" "$(cds_get_array_val "${arg_array}" "config_data_var_name")"

		# declare the function arguments for executing the container script using cdd_execute_container_script()
		local -A local_client_execute_deploy_database_args=(
				["container_scripts_path"]="$(cds_get_array_val "${arg_array}" "container_scripts_path")"
				["container_compose_file_path"]="$(cds_get_array_val "${arg_array}" "container_compose_file_path")"
				["config_data_var_name"]="$(cds_get_array_val "${arg_array}" "config_data_var_name")"
				["env_vars_block"]="$(cds_get_array_val "${arg_array}" "env_vars_block")"
				["container_name"]="$(cds_get_array_val "${arg_array}" "container_name")"
				["container_build_path"]="$(cds_get_array_val "${arg_array}" "container_build_path")"
				["container_script_type"]="$(cds_get_array_val "${arg_array}" "container_script_type")"
			)

		# execute the corresponding container scripts and shutdown the container
		cdd_execute_container_script "local_client_execute_deploy_database_args"

		echo "the local container deployment script has finished executing"
	fi
}

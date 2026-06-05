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
	if ! cds_shared_validate_required_vars	"out_var_name"; then
        echo "Error: ${FUNCNAME[0]}() function required function argument validation failed" >&2
        return 1
	fi
	
    # Calls the helper with its specific parameters
    cds_client_set_validated_var \
        "${out_var_name}" \
        "Enter destination (name of the database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "[a-zA-Z0-9_\.]+" \
        "the name of database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "${passed_value}"
}

# function that initializes the client deployment script and processes the client runtime arguments and prompts for any missing values
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# log_path: the full path to the folder that deployment logs will be saved to
# env_name: (optional) the environment name (dev, test, prod)
# deploy_dest: (optional) deployment destination (local, server)
# container_script_type: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# repo_root: the client repository root path that will have dos2unix executed for it to ensure linux compatible line endings
# scripts_path: the script path for the container scripts
function cdd_client_process_runtime_arguments ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "log_path" "repo_root" "scripts_path"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# define a pointer to the local array named ${arg_array}
	local -n arg_ref="${arg_array}"

	# process the runtime arguments using the arg_array variable that was passed as an argument
	cds_client_process_runtime_arguments "${arg_array}"

	# set the script type variable value into a local variable
	local local_script_type=""
	cdd_set_container_script_type_var "local_script_type" "${arg_ref[container_script_type]}"

	# store the validated value back into the arguments array
	cds_shared_set_array_val "${arg_array}" "container_script_type" "${local_script_type}"

	# print the runtime arguments for informational purposes
	echo ""
	echo "***************************************"
	echo "Runtime Argument Values:"
	echo "env_name: ${arg_ref[env_name]}"
	echo "deploy_dest: ${arg_ref[deploy_dest]}"
	echo "container_script_type: ${local_script_type}"
	echo "***************************************"
	echo ""

	# validate that the corresponding container script exists:
	if [ ! -f "${arg_ref[scripts_path]}/container_${local_script_type}.sh" ]; then
		echo "Error: the script type definition (script type: ${local_script_type}) argument's corresponding container deployment file does not exist: ${arg_ref[scripts_path]}/container_${local_script_type}.sh"
		return 1
	fi
}

# this function prepares and executes the client deployment scripts
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# deploy_dest: deployment destination (local, server)
# ssh_env_vars: the ssh environment variables that are passed to the server bash script call
# target_host: container hostname to connect to
# source_path: the container source directory on the container host
# git_url: git url for the container project's repository
# secret_var: name of the configuration data variable
# host_scripts_path: the path to the folder where the host bash scripts are contained
# build_path: the local container build folder path (/container_database_deployment)
# compose_path: the path of the container compose file (relative to the container build folder path)
# secret_map: the name of the associative array containing the secret names and corresponding bash variables
# scripts_path: the path to the container's bash scripts folder
# env_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# image_name: the name of the image that is being built (e.g. pifsc/great-project:latest)
# container_script_type: script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6)
function cdd_client_execute_deploy_database ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "ssh_env_vars" "deploy_dest" "target_host" "source_path" "git_url" "secret_var" "host_scripts_path" "build_path" "compose_path" "secret_map" "scripts_path" "container_name" "container_script_type" "image_name"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# define a pointer to the local array named ${arg_array}
	local -n arg_ref="${arg_array}"

	# Check if the deploy_dest variable is "server" 
	if [[ "${arg_ref[deploy_dest]}" == "server" ]]; then

		# this is a server deployment
		echo "deploy the database deployment container to the server"

		# declare the function arguments
		local -A remote_deploy_args=(
				["target_host"]="${arg_ref[target_host]}"
				["source_path"]="${arg_ref[source_path]}"
				["git_url"]="${arg_ref[git_url]}"
				["ssh_cmd"]="${arg_ref[ssh_env_vars]} bash ${arg_ref[host_scripts_path]}/host_deploy_database.sh"
				["secret_var"]="${arg_ref[secret_var]}"
				["secret_map"]="${arg_ref[secret_map]}"
				["process_secrets"]="yes"
			)
		
		# deploy the database to the remote server
		cds_client_execute_remote_deployment "remote_deploy_args"
	else
		# this is a local deployment scenario:

		# construct the argument array for cds_shared_build_deploy_container_compose()
		local -A compose_args=(
			["compose_path"]="${arg_ref[compose_path]}"
			["build_image"]="yes"
			["build_path"]="${arg_ref[build_path]}"
			["image_name"]="${arg_ref[image_name]}"
			["export_secrets"]="no"
		)

		# stop and remove any running container and build/run the container from the source code
		cds_client_deploy_local_compose "compose_args"

		# process the configuration data to pass securely via STDIN and clear the floating global bash variables
		cds_shared_process_secret_data "${arg_ref[secret_map]}" "${arg_ref[secret_var]}"

		# execute the corresponding container scripts and shutdown the container
		cdd_execute_container_script "${arg_array}"
		
		echo "the local container deployment script has finished executing"
	fi
}

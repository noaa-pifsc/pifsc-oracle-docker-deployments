#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container using an account with elevated privileges.  This function is run to build and run the container.  
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# source_path: the full path to the container source directory
# compose_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_map: the name of an associative array that maps the secret values passed to bash commands via STDIN
# secret_var: name of the configuration data variable
# image_name: the name of the image that is being built (e.g. pifsc/great-project:latest)
function cdd_host_deploy_container ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "source_path" "compose_path" "secret_map" "secret_var" "image_name"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# define a pointer to the local array named ${arg_array}
	local -n arg_ref="${arg_array}"

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $secret_var
	cds_host_process_stdin_secret_data "${arg_ref[secret_map]}" "${arg_ref[secret_var]}"

	# construct the argument array for cds_shared_build_deploy_container_compose()
	local -A local_build_deploy_container_compose_args=(
		["compose_path"]="${arg_ref[compose_path]}"
		["build_image"]="yes"
		["build_path"]="${arg_ref[source_path]}"
		["image_name"]="${arg_ref[image_name]}"
	)

	# stop and remove any running container and build/run the container from the source code
	cds_shared_build_deploy_container_compose "local_build_deploy_container_compose_args"
}

# function to deploy the database container and execute the container script
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# source_path: the full path to the container source directory
# compose_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_map: the name of an associative array that maps the secret values passed to bash commands via STDIN
# secret_var: name of the configuration data variable
# scripts_path: the path to the container's bash scripts folder
# env_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# build_path: the full path to the directory where the docker source files are located
# image_name: the name of the image that is being built (e.g. pifsc/great-project:latest)
# container_script_type: script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6)
function cdd_host_deploy_database_execute_container_script()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_host_deploy_database_execute_container_script() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "source_path" "compose_path" "secret_map" "secret_var" "scripts_path" "container_name" "build_path" "container_script_type" "image_name"; then 
        echo "Error: cdd_host_deploy_database_execute_container_script() function argument validation failed" >&2
        return 1
    fi

	# define a pointer to the local array named ${arg_array}
	local -n arg_ref="${arg_array}"

	# declare the function arguments
	local -A deploy_container_args=(
			["source_path"]="${arg_ref[source_path]}"
			["compose_path"]="${arg_ref[compose_path]}"
			["secret_var"]="${arg_ref[secret_var]}"
			["secret_map"]="${arg_ref[secret_map]}"
			["image_name"]="${arg_ref[image_name]}"
		)

	# deploy the container to the host server
	cdd_host_deploy_container "deploy_container_args"
	
	# execute the container script 
	cdd_execute_container_script "${arg_array}"
}
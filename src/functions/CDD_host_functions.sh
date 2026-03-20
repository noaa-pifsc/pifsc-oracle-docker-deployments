#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container using an account with elevated privileges.  This function is run to build and run the container.  
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# source_path: the full path to the container source directory
# compose_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_map: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_var: name of the configuration data variable
function cdd_host_deploy_container ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_host_deploy_container() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "source_path" "compose_path" "secret_map" "config_var"; then 
        echo "Error: cdd_host_deploy_container() function argument validation failed" >&2
        return 1
    fi

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $config_var
	cds_host_process_stdin_config_data "$(cds_shared_get_array_val "${arg_array}" "secret_map")" "$(cds_shared_get_array_val "${arg_array}" "config_var")"

	# construct the argument array for cds_shared_build_deploy_container_compose()
	local -A local_build_deploy_container_compose_args=(
		["compose_path"]="$(cds_shared_get_array_val "${arg_array}" "compose_path")"
		["build_image"]="yes"
		["build_path"]="$(cds_shared_get_array_val "${arg_array}" "source_path")"
		["image_name"]="$(cds_shared_get_array_val "${arg_array}" "container_name")"
	)

	# stop and remove any running container and build/run the container from the source code
	cds_shared_build_deploy_container_compose "local_build_deploy_container_compose_args"
}

# function to deploy the database container and execute the container script
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# source_path: the full path to the container source directory
# compose_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_map: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_var: name of the configuration data variable
# container_scripts_path: the path to the container's bash scripts folder
# env_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# build_path: the full path to the directory where the docker source files are located
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
	if ! cds_shared_validate_required_array_vals "${arg_array}" "source_path" "compose_path" "secret_map" "config_var" "container_scripts_path" "container_name" "build_path" "container_script_type"; then 
        echo "Error: cdd_host_deploy_database_execute_container_script() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments
	local -A deploy_container_args=(
			["source_path"]="$(cds_shared_get_array_val "${arg_array}" "source_path")"
			["compose_path"]="$(cds_shared_get_array_val "${arg_array}" "compose_path")"
			["config_var"]="$(cds_shared_get_array_val "${arg_array}" "config_var")"
			["secret_map"]="$(cds_shared_get_array_val "${arg_array}" "secret_map")"
		)

	# deploy the container to the host server
	cdd_host_deploy_container "deploy_container_args"
	
	# declare the function arguments
	local -A local_client_execute_deploy_database_args=(
			["container_scripts_path"]="$(cds_shared_get_array_val "${arg_array}" "container_scripts_path")"
			["compose_path"]="$(cds_shared_get_array_val "${arg_array}" "compose_path")"
			["config_var"]="$(cds_shared_get_array_val "${arg_array}" "config_var")"
			["env_block"]="$(cds_shared_get_array_val "${arg_array}" "env_block")"
			["container_name"]="$(cds_shared_get_array_val "${arg_array}" "container_name")"
			["build_path"]="$(cds_shared_get_array_val "${arg_array}" "build_path")"
			["container_script_type"]="$(cds_shared_get_array_val "${arg_array}" "container_script_type")"
		)

	# execute the container script 
	cdd_execute_container_script "local_client_execute_deploy_database_args"
}
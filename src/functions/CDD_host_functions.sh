#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container using an account with elevated privileges.  This function is run to build and run the container.  
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_host_source_path: the full path to the container source directory
# container_compose_file_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_mapping_var_name: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_data_var_name: name of the configuration data variable
# calling_script_path: the full path of the calling script
function cdd_host_deploy_container ()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_host_deploy_container() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_validate_required_array_vals "${arg_array}" "container_host_source_path" "container_compose_file_path" "secret_mapping_var_name" "config_data_var_name" "calling_script_path" ; then 
        echo "ERROR: cdd_host_deploy_container() function argument validation failed" >&2
        return 1
    fi

	# initialize the container environment variables
	cds_initialize_container_env_var "$(cds_get_array_val "${arg_array}" "calling_script_path")"

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $config_data_var_name
	cds_process_stdin_config_data "$(cds_get_array_val "${arg_array}" "secret_mapping_var_name")" "$(cds_get_array_val "${arg_array}" "config_data_var_name")"

	# construct the argument array for cds_build_deploy_container_compose()
	local -A local_build_deploy_container_compose_args=(
		["compose_file_path"]="$(cds_get_array_val "${arg_array}" "container_compose_file_path")"
		["container_build_image"]="yes"
		["container_build_path"]="$(cds_get_array_val "${arg_array}" "container_host_source_path")"
		["container_image_name"]="$(cds_get_array_val "${arg_array}" "container_name")"
	)

	# stop and remove any running container and build/run the container from the source code
	cds_build_deploy_container_compose "local_build_deploy_container_compose_args"
}

# function to deploy the database container and execute the container script
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_host_source_path: the full path to the container source directory
# container_compose_file_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_mapping_var_name: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_data_var_name: name of the configuration data variable
# calling_script_path: the full path of the calling script
# container_scripts_path: the path to the container's bash scripts folder
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# container_build_path: the full path to the directory where the docker source files are located
function cdd_host_deploy_database_execute_container_script()
{
	echo "running cdd_host_deploy_database_execute_container_script()"

	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_host_deploy_database_execute_container_script() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_validate_required_array_vals "${arg_array}" "container_host_source_path" "container_compose_file_path" "secret_mapping_var_name" "config_data_var_name" "calling_script_path" "container_scripts_path" "container_name" "container_build_path"; then 
        echo "ERROR: cdd_host_deploy_database_execute_container_script() function argument validation failed" >&2
        return 1
    fi

	echo "The value of arg_array is: $(cds_dump_array_vals "${arg_array}")"

	# declare the function arguments
	local -A deploy_container_args=(
			["calling_script_path"]="$(cds_get_array_val "${arg_array}" "calling_script_path")"
			["container_host_source_path"]="$(cds_get_array_val "${arg_array}" "container_host_source_path")"
			["container_compose_file_path"]="$(cds_get_array_val "${arg_array}" "container_compose_file_path")"
			["config_data_var_name"]="$(cds_get_array_val "${arg_array}" "config_data_var_name")"
			["secret_mapping_var_name"]="$(cds_get_array_val "${arg_array}" "secret_mapping_var_name")"
		)

	# deploy the container to the host server
	cdd_host_deploy_container "deploy_container_args"
	
	# declare the function arguments
	local -A local_client_execute_deploy_database_args=(
			["container_scripts_path"]="$(cds_get_array_val "${arg_array}" "container_scripts_path")"
			["container_compose_file_path"]="$(cds_get_array_val "${arg_array}" "container_compose_file_path")"
			["config_data_var_name"]="$(cds_get_array_val "${arg_array}" "config_data_var_name")"
			["env_vars_block"]="$(cds_get_array_val "${arg_array}" "env_vars_block")"
			["container_name"]="$(cds_get_array_val "${arg_array}" "container_name")"
			["container_build_path"]="$(cds_get_array_val "${arg_array}" "container_build_path")"
		)

	# execute the container script 
	cdd_execute_container_script "local_client_execute_deploy_database_args"
}
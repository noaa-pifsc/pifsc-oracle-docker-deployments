#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container using an account with elevated privileges.  This function is run to build and run the container.  
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_host_source_path: the full path to the container source directory
# container_compose_file_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_mapping_var_name: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_data_var_name: name of the configuration data variable
# calling_script_path: the full path of the calling script
function host_deploy_container_elev_privs ()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: host_deploy_container_elev_privs() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "container_host_source_path" "container_compose_file_path" "secret_mapping_var_name" "config_data_var_name" "calling_script_path" ; then 
        echo "ERROR: host_deploy_container_elev_privs() function argument validation failed" >&2
        return 1
    fi

	# initialize the container environment variables
	initialize_container_env_var "$(get_array_val "${arg_array}" "calling_script_path")"

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $config_data_var_name
	process_stdin_config_data "$(get_array_val "${arg_array}" "secret_mapping_var_name")" "$(get_array_val "${arg_array}" "config_data_var_name")"

	# change to the container container directory
	cd "$(get_array_val "${arg_array}" "container_host_source_path")"

	# build and run the sqlplus container
	echo "build and run the sqlplus container"
	build_deploy_container_compose "$(get_array_val "${arg_array}" "container_compose_file_path")"
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
function host_deploy_database_execute_container_script()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: host_deploy_database_execute_container_script() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "container_host_source_path" "container_compose_file_path" "secret_mapping_var_name" "config_data_var_name" "calling_script_path" "container_scripts_path" "container_name"; then 
        echo "ERROR: host_deploy_database_execute_container_script() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments
	local -A DEPLOY_FUNC_ARGS=(
			["calling_script_path"]="$(get_array_val "${arg_array}" "calling_script_path")"
			["container_host_source_path"]="$(get_array_val "${arg_array}" "container_host_source_path")"
			["container_compose_file_path"]="$(get_array_val "${arg_array}" "container_compose_file_path")"
			["config_data_var_name"]="$(get_array_val "${arg_array}" "config_data_var_name")"
			["secret_mapping_var_name"]="$(get_array_val "${arg_array}" "secret_mapping_var_name")"
		)

	# deploy the container to the host server
	host_deploy_container_elev_privs "DEPLOY_FUNC_ARGS"
	
	# declare the function arguments
	local -A EXEC_FUNC_ARGS=(
			["container_scripts_path"]="$(get_array_val "${arg_array}" "container_scripts_path")"
			["container_compose_file_path"]="$(get_array_val "${arg_array}" "container_compose_file_path")"
			["config_data_var_name"]="$(get_array_val "${arg_array}" "config_data_var_name")"
			["env_vars_block"]="$(get_array_val "${arg_array}" "env_vars_block")"
			["container_name"]="$(get_array_val "${arg_array}" "container_name")"
		)

	# execute the container script 
	execute_container_script "EXEC_FUNC_ARGS"
}
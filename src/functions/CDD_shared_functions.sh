#!/bin/bash

# function to run the oracle database scripts within the running container. This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_scripts_path: the path to the container's bash scripts folder
# container_compose_file_path: the path of the container compose file
# config_data_var_name: name of the configuration data variable
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
function execute_container_script ()
{
	echo "running execute_container_script()"
	
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: execute_container_script() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! validate_required_array_vals "${arg_array}" "container_scripts_path" "container_compose_file_path" "config_data_var_name"; then 
        echo "ERROR: execute_container_script() function argument validation failed" >&2
        return 1
    fi
	
	# validate the bash variable values
	if ! validate_required_vars	"SCRIPT_TYPE"; then
        echo "ERROR: execute_container_script() function required bash variable validation failed" >&2
        return 1
	fi

	# construct the full path to the script that will be executed within the container (${SCRIPT_TYPE} is passed in as an environment variable):
	local script_path="$(get_array_val "${arg_array}" "container_scripts_path")/container_${SCRIPT_TYPE}.sh"

	# store the values of the variables used in local variables
	local env_vars_block="$(get_array_val "${arg_array}" "env_vars_block")"
	local config_data_var_name="$(get_array_val "${arg_array}" "config_data_var_name")"

	echo "run the container_${SCRIPT_TYPE}.sh script from within the container to execute the corresponding automated scripts"

# open a bash session into the running container and run the appropriate container deployment script (based on $SCRIPT_TYPE) and provide the value of the variable identified by $config_data_var_name via stdin
docker exec -i oracle_deploy bash -c "
	# specify the environment variables that are defined in the calling script:
	${env_vars_block}
	
	# Execute the target script, which will inherit the variables above.
	bash '${script_path}'
" <<< "${!config_data_var_name}"

	# shutdown and cleanup the container project
	shutdown_cleanup_container "$(get_array_val "${arg_array}" "config_data_var_name")" "$(get_array_val "${arg_array}" "container_compose_file_path")"
}



# function to shutdown the container and cleanup the container target folder after the container scripts have been executed. This function is run to shutdown the container. This function accepts 2 parameters:
# 1: the name of the configuration data variable used to store the STDIN data
# 2: the path of the container compose file (relative to the container_database_deployment source directory - see CONTAINER_HOST_SOURCE_PATH in host_deploy_container_elev_privs())
# Example Usage: 
# shutdown_cleanup_container "CONFIG_DATA" "./docker-compose.yml" 
function shutdown_cleanup_container ()
{
	echo "running shutdown_cleanup_container()"
	
	local config_data_var_name="${1}"
	local container_compose_file_path="${2}"

	# validate the bash variable values
	if ! validate_required_vars	"config_data_var_name" "container_compose_file_path"; then
        echo "ERROR: shutdown_cleanup_container() function required bash variable validation failed" >&2
        return 1
	fi

	echo "shutdown the container and cleanup the container target folder"

	# unset the variable named $config_data_var_name
	unset_config_data "${config_data_var_name}"

	# when the deployment has been completed, shutdown the container
 	shutdown_container "${container_compose_file_path}"
}

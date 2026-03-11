#!/bin/bash

# function to run the oracle database scripts within the running container. This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_scripts_path: the path to the container's bash scripts folder
# container_compose_file_path: the path of the container compose file
# config_data_var_name: name of the configuration data variable
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# container_build_path: the local container build folder path (/container_database_deployment)
function cdd_execute_container_script ()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: cdd_execute_container_script() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "container_scripts_path" "container_compose_file_path" "config_data_var_name" "container_name" "container_build_path" "container_script_type"; then 
        echo "Error: cdd_execute_container_script() function argument validation failed" >&2
        return 1
    fi
	
	# store the script type value while still in scope
	
	# Grab the specific array values while the local array is still in scope
	local trap_config_data="$(cds_shared_get_array_val "${arg_array}" "config_data_var_name")"
	local trap_compose_path="$(cds_shared_get_array_val "${arg_array}" "container_compose_file_path")"
	local trap_build_path="$(cds_shared_get_array_val "${arg_array}" "container_build_path")"

	# Guarantee cleanup: Register an EXIT trap to ensure the container is always torn down. By using double quotes, the literal string values are specified as arguments before the cds_shared_execute_container_script() functon is run
	trap "cds_shared_shutdown_cleanup_container_compose '${trap_config_data}' '${trap_compose_path}' '${trap_build_path}'" EXIT

	# construct arguments for the cds_shared_execute_container_script() function
	local -A execute_container_script_args=(
			["script_path"]="$(cds_shared_get_array_val "${arg_array}" "container_scripts_path")/container_$(cds_shared_get_array_val "${arg_array}" "container_script_type").sh"
			["config_data_var_name"]="${trap_config_data}"
			["env_vars_block"]="$(cds_shared_get_array_val "${arg_array}" "env_vars_block")"
			["container_name"]="$(cds_shared_get_array_val "${arg_array}" "container_name")"
		)

	# execute the script within the specified container
	cds_shared_execute_container_script "execute_container_script_args"
}

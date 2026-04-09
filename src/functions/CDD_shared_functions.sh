#!/bin/bash

# function to run the database scripts within the running container. This function accepts the following parameters as elements in the specified array name  (arg_array):
# scripts_path: the path to the container's bash scripts folder
# compose_path: the path of the container compose file
# secret_var: name of the configuration data variable
# env_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
# container_name: the name of the container that will have the database deployment script executed for it
# build_path: the local container build folder path (/container_database_deployment)
# container_script_type: script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6)
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
	if ! cds_shared_validate_required_array_vals "${arg_array}" "scripts_path" "compose_path" "secret_var" "container_name" "build_path" "container_script_type"; then 
        echo "Error: cdd_execute_container_script() function argument validation failed" >&2
        return 1
    fi
	
	# store the script type value while still in scope
	
	# store the specific array values while the local array is still in scope
	local trap_secret_var="$(cds_shared_get_array_val "${arg_array}" "secret_var")"
	local trap_compose_path="$(cds_shared_get_array_val "${arg_array}" "compose_path")"
	local trap_build_path="$(cds_shared_get_array_val "${arg_array}" "build_path")"

	# register an exit trap to ensure the container is always torn down. By using double quotes, the literal string values are specified as arguments before the cds_shared_execute_container_script() functon is run
	trap "cds_shared_shutdown_cleanup_container_compose '${trap_secret_var}' '${trap_compose_path}' '${trap_build_path}'" EXIT

	# construct arguments for the cds_shared_execute_container_script() function
	local -A execute_container_script_args=(
			["script_path"]="$(cds_shared_get_array_val "${arg_array}" "scripts_path")/container_$(cds_shared_get_array_val "${arg_array}" "container_script_type").sh"
			["secret_var"]="$(cds_shared_get_array_val "${arg_array}" "secret_var")"
			["env_block"]="$(cds_shared_get_array_val "${arg_array}" "env_block")"
			["container_name"]="$(cds_shared_get_array_val "${arg_array}" "container_name")"
		)

	# execute the script within the specified container
	cds_shared_execute_container_script "execute_container_script_args"
}

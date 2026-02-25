#!/bin/bash

# function to initialize the container by parsing the configuration data, changing the directory to the container SQL directory, and generating the database connection scripts. Input validation is handled by container_initialize_script()
# this function accepts 3 parameters: 
# 1: the full script path name that was executed
# 2: the full path to the designated SQL folder within the container
# 3: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage: 
# container_initialize "$0" "/usr/src/oracle_deploy/SQL" "SECRET_MAPPING_ARR"
function container_initialize()
{
	local calling_script_path="${1}"
	local container_root_sql_path="${2}"
	local secret_mapping_var_name="${3}"

	# input validation
	if ! validate_required_vars	"calling_script_path" "container_root_sql_path"; then
        echo "ERROR: container_initialize() function required bash variable validation failed" >&2
        return 1
    fi

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${secret_mapping_var_name}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: container_cleanup() function argument '${secret_mapping_var_name}' is not a valid associative array." >&2
        return 1
    fi

	# initialize the container scripts
	container_initialize_script "${calling_script_path}" "${container_root_sql_path}" "${secret_mapping_var_name}"

	# generate the database connection strings so they can be used to execute the SQLPlus scripts
	container_generate_connection_strings
}

# function that cleans up container variables after the sqlplus scripts complete, it accepts 1 parameter:
# 1: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage: 
# container_cleanup "SECRET_MAPPING_ARR"
function container_cleanup ()
{
	local secret_mapping_var_name="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${secret_mapping_var_name}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: container_cleanup() function argument '${secret_mapping_var_name}' is not a valid associative array." >&2
        return 1
    fi

	# unset bash variables specified by STDIN
	generic_unset_config_variables "${secret_mapping_var_name}"

	# unset the connection string variables
	container_unset_connection_strings
}

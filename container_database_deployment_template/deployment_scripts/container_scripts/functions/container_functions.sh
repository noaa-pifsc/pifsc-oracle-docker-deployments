#!/bin/bash

# function to initialize the container by parsing the configuration data, changing the directory to the container SQL directory, and generating the database connection scripts. 
# this function accepts 3 or more parameters: 
# 1: the full script path name that was executed
# 2: the full path to the designated SQL folder within the container
# 3: the name of an associative array that maps the secret values passed to bash commands via STDIN
# 4-n: an arbitrary number of variable names to output the connection strings to (passed to project-specific generator)
# Example Usage: 
# container_initialize "$0" "/usr/src/oracle_deploy/SQL" "SECRET_MAPPING_ARR" "DB_CONN_STRING" "DB_GIM_CONN_STRING" "DB_RIA_CONN_STRING"
function container_initialize()
{
	local calling_script_path="${1}"
	local container_root_sql_path="${2}"
	local secret_mapping_var_name="${3}"

	# input validation
	if ! cds_validate_required_vars	"calling_script_path" "container_root_sql_path" "secret_mapping_var_name"; then
        echo "Error: container_initialize() function required bash variable validation failed" >&2
        return 1
    fi

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${secret_mapping_var_name}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: container_initialize() function argument '${secret_mapping_var_name}' is not a valid associative array." >&2
        return 1
    fi

	# shift the first 3 core arguments out of the way so $@ only contains the connection string variable names
	shift 3

	# declare the strictly scoped array to safely catch the secrets
	local -A LOCAL_SECRETS_ARR=()

	# call the pure CDD core to initialize and populate the secure array
	cdd_container_initialize_script "${calling_script_path}" "${container_root_sql_path}" "${secret_mapping_var_name}" "LOCAL_SECRETS_ARR" || return 1

	# pass the secure array and any remaining arguments ($@) dynamically to the project-specific connection string generator
	container_generate_connection_strings "LOCAL_SECRETS_ARR" "$@" || return 1
}

# function that cleans up container variables after the sqlplus scripts complete, it accepts 1 parameter:
# 1: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage: 
# container_cleanup "SECRET_MAPPING_ARR"
function container_cleanup ()
{
	local secret_mapping_var_name="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${secret_mapping_var_name}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: container_cleanup() function argument '${secret_mapping_var_name}' is not a valid associative array." >&2
        return 1
    fi

	# unset bash variables specified by STDIN
	cds_generic_unset_config_variables "${secret_mapping_var_name}"
}

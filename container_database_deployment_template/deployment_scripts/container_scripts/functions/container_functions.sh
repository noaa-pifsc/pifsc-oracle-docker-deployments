#!/bin/bash

# function to initialize the container by parsing the configuration data, changing the directory to the container SQL directory, and generating the database connection scripts. 
# this function accepts 3 or more parameters: 
# 1: the full path to the designated SQL folder within the container
# 2: the name of an associative array that maps the secret values passed to bash commands via STDIN
# 3-n: an arbitrary number of variable names to output the connection strings to (passed to project-specific generator)
# Example Usage: 
# proj_container_initialize "/usr/src/database_deploy/SQL" "SECRET_MAPPING_ARR" "db_conn_string" "db_gim_conn_string" "db_ria_conn_string"
function proj_container_initialize()
{
	local container_root_sql_path="${1}"
	local secret_map="${2}"

	# input validation
	if ! cds_shared_validate_required_vars "container_root_sql_path" "secret_map"; then
        echo "Error: proj_container_initialize() function required bash variable validation failed" >&2
        return 1
    fi

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${secret_map}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: proj_container_initialize() function argument '${secret_map}' is not a valid associative array." >&2
        return 1
    fi

	# shift the first 3 core arguments out of the way so $@ only contains the connection string variable names
	shift 2

	# declare the strictly scoped array to safely catch the secrets
	local -A local_secrets_arr=()

	# call the pure CDD core to initialize and populate the secure array
	cdd_container_initialize_script "${container_root_sql_path}" "${secret_map}" "local_secrets_arr" || return 1

	# pass the secure array and any remaining arguments ($@) dynamically to the project-specific connection string generator
	proj_container_generate_connection_strings "local_secrets_arr" "$@" || return 1
}

# function that cleans up container variables after the sqlplus scripts complete, it accepts 1 parameter:
# 1: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage: 
# proj_container_cleanup "SECRET_MAPPING_ARR"
function proj_container_cleanup ()
{
	local secret_map="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${secret_map}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: proj_container_cleanup() function argument '${secret_map}' is not a valid associative array." >&2
        return 1
    fi

	# unset bash variables specified by STDIN
	cds_shared_unset_config_variables "${secret_map}"
}

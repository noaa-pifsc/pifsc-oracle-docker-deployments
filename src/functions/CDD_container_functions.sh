#!/bin/bash

# function to initialize the container scripts by parsing the configuration data and changing the directory to the container SQL directory
# this function accepts 3 parameters: 
# 1: the full script path name that was executed
# 2: the full path to the designated SQL folder within the container
# 3: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage:  
# container_initialize_script "$0" "/usr/src/oracle_deploy/SQL" "SECRET_MAPPING_ARR"
function container_initialize_script ()
{
	# retrieve the current script name that was originally invoked
	get_script_name_from_path "${1}"

	local container_sql_directory="${2}"
	local secret_mapping_var_name="${3}"
	
	# input validation
	if ! validate_required_vars	"container_sql_directory" "secret_mapping_var_name"; then
        echo "ERROR: container_initialize_script() function required bash variable validation failed" >&2
        return 1
    fi

	# read the key/value pairs from STDIN and store them in bash variables
	generic_parse_config_data "${secret_mapping_var_name}"

	# change the current directory to the designated SQL folder where the SQLPlus scripts can be executed using relative paths
	cd "${container_sql_directory}"
}
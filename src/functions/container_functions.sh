#!/bin/bash

# function to initialize the container scripts by parsing the configuration data and changing the directory to the container SQL directory
# this function accepts 3 parameters: 
# 1: the full script path name that was executed
# 2: the full path to the designated SQL folder within the container
# 3: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage:  
# initialize_container_script "$0" "/usr/src/oracle_deploy/SQL" "SECRET_MAPPING_ARR"
function initialize_container_script ()
{
	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	local container_sql_directory="$2"
	local secret_mapping_var="$3"
	
	# input validation
    if [[ -z "$container_sql_directory" || -z "$secret_mapping_var" ]]; then
        echo "ERROR: initialize_container_script() requires the full path to the designated SQL directory within the container and the name of an associative array that maps the secret values passed to bash commands via STDIN as arguments" >&2
        return 1
    fi

	# read the key/value pairs from STDIN and store them in bash variables
	generic_parse_config_data "$secret_mapping_var"

	# change the current directory to the designated SQL folder where the SQLPlus scripts can be executed using relative paths
	cd "$container_sql_directory"
}


# function that cleans up container variables after the sqlplus scripts complete, it accepts 1 parameter:
# 1: the name of an associative array that maps the secret values passed to bash commands via STDIN
# Example Usage:  
# cleanup_container_variables "SECRET_MAPPING_ARR"
function cleanup_container_variables ()
{
	local secret_mapping_var="$1"

	# input validation
    if [[ -z "$secret_mapping_var" ]]; then
        echo "ERROR: cleanup_container_variables() requires the name of an associative array that maps the secret values passed to bash commands via STDIN as an argument" >&2
        return 1
    fi

	# unset bash variables specified by STDIN
	generic_unset_config_variables "$secret_mapping_var"
}

#!/bin/bash

# function to initialize the container scripts by parsing the configuration data and changing the directory to the container SQL directory
# this function accepts 4 parameters: 
# 1: the full path to the designated SQL folder within the container
# 2: the name of an associative array that maps the secret values passed to bash commands via STDIN
# 3: the name of the output associative array where parsed secrets will be safely stored (scoped to the calling function).
# Example Usage:  
# cdd_container_initialize_script "$0" "/usr/src/database_deploy/SQL" "SECRET_MAPPING_ARR" "parsed_secrets_arr"
function cdd_container_initialize_script ()
{
	local container_sql_directory="${1}"
	local secret_map="${2}"
	local output_parsed_secrets_var_name="${3}"
	
	# input validation
	if ! cds_shared_validate_required_vars	"container_sql_directory" "secret_map" "output_parsed_secrets_var_name"; then
        echo "Error: cdd_container_initialize_script() function required bash variable validation failed" >&2
        return 1
    fi

	# Declare the scoped variable for sensitive data processing
	local raw_stdin=""

	# read the raw STDIN passed securely via the pipeline
	if [[ ! -t 0 ]]; then raw_stdin=$(cat); fi

	# parse the raw_stdin into the calling function's local associative array
	cds_shared_parse_secret_data "${secret_map}" "${output_parsed_secrets_var_name}" <<< "${raw_stdin}"

	# change the current directory to the designated SQL folder where the SQLPlus scripts can be executed using relative paths
	cd "${container_sql_directory}"
}
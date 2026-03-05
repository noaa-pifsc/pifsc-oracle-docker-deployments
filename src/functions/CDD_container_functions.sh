#!/bin/bash

# function to initialize the container scripts by parsing the configuration data and changing the directory to the container SQL directory
# this function accepts 4 parameters: 
# 1: the full script path name that was executed
# 2: the full path to the designated SQL folder within the container
# 3: the name of an associative array that maps the secret values passed to bash commands via STDIN
# 4: the name of the output associative array where parsed secrets will be safely stored (scoped to the calling function).
# Example Usage:  
# cdd_container_initialize_script "$0" "/usr/src/oracle_deploy/SQL" "SECRET_MAPPING_ARR" "PARSED_SECRETS_ARR"
function cdd_container_initialize_script ()
{
	# retrieve the current script name that was originally invoked
	cds_get_script_name_from_path "${1}"

	local container_sql_directory="${2}"
	local secret_mapping_var_name="${3}"
	local output_parsed_secrets_var_name="${4}"
	
	# input validation
	if ! cds_validate_required_vars	"container_sql_directory" "secret_mapping_var_name" "output_parsed_secrets_var_name"; then
        echo "ERROR: cdd_container_initialize_script() function required bash variable validation failed" >&2
        return 1
    fi

	# Declare the scoped variable for sensitive data processing
	local RAW_STDIN=""

	# read the raw STDIN passed securely via the pipeline
	if [[ ! -t 0 ]]; then RAW_STDIN=$(cat); fi

	# parse the RAW_STDIN into the calling function's local associative array
	cds_generic_parse_config_data "${secret_mapping_var_name}" "${output_parsed_secrets_var_name}" <<< "${RAW_STDIN}"

	# change the current directory to the designated SQL folder where the SQLPlus scripts can be executed using relative paths
	cd "${container_sql_directory}"
}
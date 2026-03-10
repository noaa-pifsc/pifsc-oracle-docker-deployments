#!/bin/bash

# function to generate oracle connection strings securely into scoped local variables
# this function accepts 4 parameters:
# 1: the name of the secure array containing the parsed secrets
# 2-n: the names of the variables to output the connection strings to
# Usage:
# container_generate_connection_strings "SECURE_SECRETS_ARR" "DB_CONN_STRING" "DB_GIM_CONN_STRING" "DB_RIA_CONN_STRING"
function container_generate_connection_strings ()
{
	local parsed_secrets_arr_name="${1}"

	# input validation
	if ! cds_validate_required_vars	"DB_HOST" "DB_SERVICE_NAME"; then
        echo "Error: container_generate_connection_strings() function required bash variable validation failed" >&2
        return 1
    fi 

    # validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: container_generate_connection_strings() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# Create a nameref to safely read from the parsed secrets array
	local -n secrets_arr="${parsed_secrets_arr_name}"
	
	######## Database Connection Placeholder - START ########
	
	# declare separate local variable for each database connection string used in database deployments
	# Example:
	# local out_data_conn_ref="${2}"
	# local out_app_conn_ref="${3}"

	# validate that the required secret keys exist safely within the securely parsed array
	# Example:
	# if ! cds_validate_required_array_vals "${parsed_secrets_arr_name}" "ORACLE_DB_USER" "ORACLE_DB_PASS" "ORACLE_DB_APP_USER" "ORACLE_DB_APP_PASS"; then
    #    echo "Error: container_generate_connection_strings() function required secure array validation failed" >&2
    #    return 1
	#fi

	# Create namerefs to safely assign values to the caller's local variables
	# Examples:
	# local -n data_conn="${out_data_conn_ref}"
	# local -n app_conn="${out_app_conn_ref}"


	# construct connection strings securely (enclose the passwords in quotation characters in case there are special characters)
	# Examples: 
	# data_conn="${secrets_arr[ORACLE_DB_USER]}/\"${secrets_arr[ORACLE_DB_PASS]}\"@${DB_HOST}/${DB_SERVICE_NAME}"
	# app_conn="${secrets_arr[ORACLE_DB_APP_USER]}/\"${secrets_arr[ORACLE_DB_APP_PASS]}\"@${DB_HOST}/${DB_SERVICE_NAME}"
	######## Database Connection Placeholder - END ########
}
}
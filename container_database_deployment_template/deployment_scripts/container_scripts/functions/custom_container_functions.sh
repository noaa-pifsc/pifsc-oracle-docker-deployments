#!/bin/bash

# function to generate oracle connection strings for the various database schemas the script connects to
# this function accepts no parameters
# Usage:
# container_generate_connection_strings
function container_generate_connection_strings ()
{

	######## Database Connection Placeholder - START ########
	# validate the bash variable values
	# Example:
#	if ! cds_validate_required_vars	"ORACLE_DB_USER" "ORACLE_DB_PASS" "DB_HOST" "DB_SERVICE_NAME" "ORACLE_DB_APP_USER" "ORACLE_DB_APP_PASS"; then
#        echo "ERROR: container_generate_connection_strings() function required bash variable validation failed" >&2
#        return 1
#	fi

	# construct connection strings (enclose the passwords in quotation characters in case there are special characters including "@")


	# define the global bash variables that provide the required database connection strings necessary to execute the database deployment scripts 

	# Examples: 
	# DB_CONN_STRING="${ORACLE_DB_USER}/\"${ORACLE_DB_PASS}\"@${DB_HOST}/${DB_SERVICE_NAME}"
	# DB_APP_CONN_STRING="${ORACLE_DB_APP_USER}/\"${ORACLE_DB_APP_PASS}\"@${DB_HOST}/${DB_SERVICE_NAME}"

	######## Database Connection Placeholder - END ########

}

# function to unset the connection bash variables
# this function accepts no parameters
# Usage:
# container_unset_connection_strings
function container_unset_connection_strings()
{

	######## Database Connection Placeholder - START ########
	# unset each of the connection string variables (separated by spaces)

	# Example:
	# unset DB_CONN_STRING DB_APP_CONN_STRING

	######## Database Connection Placeholder - END ########

}
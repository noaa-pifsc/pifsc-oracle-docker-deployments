#!/bin/bash

# function to initialize the container script
# this function accepts 2 parameters: the full script path name that was executed and the environment name (dev, qa, prod)
# Usage:
# initialize_container_script "$0" "$1"
function initialize_container_script ()
{
	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	echo "running $CURRENT_SCRIPT_NAME"

	# get the ENV_NAME value from the bash script parameter value
#	ENV_NAME="$2"
#	echo "ENV_NAME is: $ENV_NAME"


	# read the key/value pairs from STDIN and store them in bash variables
	parse_config_data

	# construct database connection strings
	generate_connection_strings

	# change to the directory that contains the SQL scripts so the sqlplus commands can run with relative paths
	cd /usr/src/oracle_deploy/SQL
}

# function that cleans up container variables after the sqlplus scripts complete
function cleanup_container_variables ()
{
	echo "running cleanup_container_variables()"

	# unset bash variables specified by STDIN
	unset_config_variables

	# unset the connection string variables
	unset_connection_strings

	echo "$CURRENT_SCRIPT_NAME has finished executing";

}

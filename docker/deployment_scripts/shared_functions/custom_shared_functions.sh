#!/bin/bash

# this function parses the standard configuration data that is provided to bash scripts via stdin and stores them in the corresponding bash variables
# this function accepts no parameters
function parse_config_data()
{
	# read each of the lines from stdin
	while IFS='=' read -r key value; do

		# check if the current key value matches any of the expected values
		case "$key" in
			ORACLE_DB_USER) ORACLE_DB_USER="$value";;
			ORACLE_DB_PASS) ORACLE_DB_PASS="$value";;
			ORACLE_DB_APP_USER) ORACLE_DB_APP_USER="$value";;
			ORACLE_DB_APP_PASS) ORACLE_DB_APP_PASS="$value";;
			SCRIPT_TYPE) SCRIPT_TYPE="$value";;
			*)
				# output warning message to stderr
				echo "Warning: unknown configuration key '$key' ignored" >&2
				;;
		esac
	done

}

# this function encodes the standard configuration data stored in bash variables so it can be passed to bash scripts via stdin
# this function accepts no parameters
function encode_config_data ()
{
	# generate each key/value pair for use in stdin
	printf 'ORACLE_DB_USER=%s\n' "$ORACLE_DB_USER"
	printf 'ORACLE_DB_PASS=%s\n' "$ORACLE_DB_PASS"
	printf 'ORACLE_DB_APP_USER=%s\n' "$ORACLE_DB_APP_USER"
	printf 'ORACLE_DB_APP_PASS=%s\n' "$ORACLE_DB_APP_PASS"
	printf 'SCRIPT_TYPE=%s\n' "$SCRIPT_TYPE"

}


# function to unset bash variables specified by STDIN:
function unset_config_variables()
{
	unset ORACLE_DB_USER ORACLE_DB_PASS ORACLE_DB_APP_USER ORACLE_DB_APP_PASS SCRIPT_TYPE
}

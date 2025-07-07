#!/bin/bash

# this function parses the standard configuration data that is provided to bash scripts via stdin and stores them in the corresponding bash variables
# this function accepts no parameters
function parse_config_data()
{
	echo "running parse_config_data()"


	while IFS='=' read -r key value; do
		case "$key" in
			ORACLE_DB_HOST) ORACLE_DB_HOST="$value";;
			ORACLE_DB_USER) ORACLE_DB_USER="$value";;
			ORACLE_DB_PASS) ORACLE_DB_PASS="$value";;
			ORACLE_DB_APP_USER) ORACLE_DB_APP_USER="$value";;
			ORACLE_DB_APP_PASS) ORACLE_DB_APP_PASS="$value";;
			SCRIPT_TYPE) SCRIPT_TYPE="$value";;
			ENV_NAME) ENV_NAME="$value";;
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
	printf 'ORACLE_DB_HOST=%s\n' "$ORACLE_DB_HOST"
	printf 'ORACLE_DB_USER=%s\n' "$ORACLE_DB_USER"
	printf 'ORACLE_DB_PASS=%s\n' "$ORACLE_DB_PASS"
	printf 'ORACLE_DB_APP_USER=%s\n' "$ORACLE_DB_APP_USER"
	printf 'ORACLE_DB_APP_PASS=%s\n' "$ORACLE_DB_APP_PASS"
	printf 'SCRIPT_TYPE=%s\n' "$SCRIPT_TYPE"
	printf 'ENV_NAME=%s\n' "$ENV_NAME"

}


# function to unset bash variables specified by STDIN:
function unset_config_variables()
{
	unset ORACLE_DB_HOST ORACLE_DB_USER ORACLE_DB_PASS ORACLE_DB_APP_USER ORACLE_DB_APP_PASS SCRIPT_TYPE ENV_NAME
}

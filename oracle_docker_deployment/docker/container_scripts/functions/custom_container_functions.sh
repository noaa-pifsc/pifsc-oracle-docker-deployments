#!/bin/bash

# function to generate oracle connection strings for the various database schemas the script connects to
# this function accepts no parameters
# Usage:
# generate_connection_strings
function generate_connection_strings ()
{
	# construct connection strings (enclose the passwords in quotation characters in case there are special characters including "@")
	DB_CONN_STRING="${ORACLE_DB_USER}/\"${ORACLE_DB_PASS}\"@${ORACLE_DB_HOST}"
	DB_APP_CONN_STRING="${ORACLE_DB_APP_USER}/\"${ORACLE_DB_APP_PASS}\"@${ORACLE_DB_HOST}"

}

# function to unset the connection bash variables
# this function accepts no parameters
# Usage:
# unset_connection_strings
function unset_connection_strings()
{
	# unset the connection string variables
	unset DB_CONN_STRING DB_APP_CONN_STRING
}

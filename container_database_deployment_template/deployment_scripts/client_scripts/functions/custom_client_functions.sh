#!/bin/bash

# function to load the client configuration files (secrets and environment server configuration)
function client_load_config_files()
{
	# validate the bash variable values
	if ! validate_required_vars	"CONTAINER_ENV_NAME"; then
        echo "ERROR: client_load_config_files() function required bash variable validation failed" >&2
        return 1
	fi

	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# load the bash variables for the runtime configuration (/container_database_deployment/deployment_scripts/config)
	source "${curr_dir}/../../config/deploy_config.${CONTAINER_ENV_NAME}.sh"
	
	# load the oracle credentials into bash variables (/container_database_deployment/secrets/$CONTAINER_ENV_NAME)
	source "${curr_dir}/../../../secrets/${CONTAINER_ENV_NAME}/secrets.sh"
}

# function to define the ssh environment variables for the database deployment server bash script 
function client_generate_ssh_env_vars ()
{
	######## Environment Variable String Placeholder - START ########
	# validate the bash variable values
	# Example:
# 	if ! validate_required_vars	"SCRIPT_TYPE" "DB_HOST" "DB_SERVICE_NAME" "CONTAINER_ENV_NAME"; then
#        echo "ERROR: client_generate_ssh_env_vars() function required bash variable validation failed" >&2
#        return 1
#	fi
	# construct the ssh environment variables that are passed to the server bash script call based on the global bash variable values

	# Example:
	# echo "SCRIPT_TYPE=\"${SCRIPT_TYPE}\" DB_HOST=\"${DB_HOST}\" DB_SERVICE_NAME=\"${DB_SERVICE_NAME}\" CONTAINER_ENV_NAME=\"${CONTAINER_ENV_NAME}\""
	
	######## Environment Variable String Placeholder - END ########
}
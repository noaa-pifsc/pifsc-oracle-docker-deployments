#!/bin/bash

# this file contains custom client functions used for specific data systems


# function that transfers any special files to the host server (when applicable), this is meant to be changed for a given database/APEX implementation.  This function accepts no parameters
# Usage:
# transfer_special_files
function transfer_special_files()
{
	#################################################
	######## Project-Specific Code Goes Here ########
	#################################################

}


# this function prepares and executes the client deployment scripts
# this function accepts 2 parameters: the environment name (dev, qa, prod), and the ssh username used to connect to the remote docker host
# Usage:
#   prepare_deployment_script "$1" "$2"
function prepare_execute_deployment_script ()
{
	local passed_env_name="$1"

	# save/prompt for environment name and ssh username variables
	set_env_var "$passed_env_name" 

#	echo "The value of ENV_NAME is: $ENV_NAME"

	# convert all the .sh files in the parent directory to unix line endings
	convert_dos2unix "../"

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	source ../config/docker_host_config.sh

	echo "Prepare the docker host"

	# Prepare the docker host by cloning the repository and copying the appropriate source files into the docker folder
	prepare_docker_host

	# Transfer any special files (if any) to the docker host from the client machine
	transfer_special_files

	# load the oracle credentials into bash variables
	source ../../secrets/$ENV_NAME/secrets.sh

	# compile stdin credential/configuration variables:
	CONFIG_DATA=$(encode_config_data)

	# unset the sensitive bash variables so they can't be reused
	unset_config_variables

	# execute the docker deployment script on the host server and specify the sensitive values as stdin and the configuration values as environment variables
	exec_remote_cmd_with_stdin "$CONFIG_DATA" "DB_HOST=\"$DB_HOST\" DB_SERVICE_NAME=\"$DB_SERVICE_NAME\" ENV_NAME=\"$ENV_NAME\" bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/initiate_docker.sh"

	# unset the CONFIG_DATA now that the plink call has completed
	unset CONFIG_DATA

	echo "The $CURRENT_SCRIPT_NAME script finished executing"

}

# function that prepares the docker host by creating the temporary directory structure, copying the initial .sh and .env files for the host and executes the prepare_docker_host.sh script.  This function accepts no parameters
# Usage:
# prepare_docker_host
function prepare_docker_host ()
{
	# remove the temporary directory, create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts, and clone the repository
	exec_remote_cmd "rm -rf '${DOCKER_SOURCE_DIR}' && mkdir -p '${DOCKER_SOURCE_DIR}' && git clone ${DOCKER_GIT_URL} ${DOCKER_SOURCE_DIR}"

	# execute the prepare_docker_host.sh script on the host server
	exec_remote_cmd "bash $DOCKER_SOURCE_DIR/docker/deployment_scripts/host_scripts/prepare_docker_host.sh"
}


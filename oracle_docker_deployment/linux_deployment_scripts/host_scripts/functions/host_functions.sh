#!/bin/bash

# function that loads the function parameter to the ENV_NAME variable and loads the environment variables from docker_host.env
# the first parameter is the script path that was executed
# Usage:
# initialize_docker_env_var "$0"
function initialize_docker_env_var ()
{
	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	echo "running $CURRENT_SCRIPT_NAME"

	# load the configuration variables
	source ../config/docker_host_config.sh
}

# function that initializes the docker source folder on the remote host ($DOCKER_SOURCE_DIR).  This function accepts no parameters
# Usage:
# initialize_docker_source_folder
function initialize_docker_source_folder ()
{
	# change permissions so docker-user can copy the necessary files
	chmod -R 755 "$DOCKER_SOURCE_DIR"
}

# function cleanup the docker source folder by removing the temporary files used to build/deploy the project.  This function accepts no parameters
# Usage:
# cleanup_docker_source_folder
function cleanup_docker_source_folder ()
{
# 	echo "running cleanup_docker_source_folder()"
	echo "The $CURRENT_SCRIPT_NAME script has finished executing, remove the files in $DOCKER_SOURCE_DIR"

	# unset the CONFIG_DATA variable
	unset CONFIG_DATA

	# remove the docker source files:
	rm -rf "$DOCKER_SOURCE_DIR"

	echo "$CURRENT_SCRIPT_NAME has finished running"

}


# function to initialize the docker target folder (where the docker project will be built/run) and build/run the container.  This function accepts no parameters
# Usage:
# initialize_run_docker_project
function initialize_run_docker_project ()
{
	# load the configuration variables
	source ../config/docker_host_config.sh

	# create the docker target directory
	mkdir -p "$DOCKER_TARGET_DIR/src"

	# copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
	prepare_docker_target_dir

	# change to the docker container directory
# 	echo "Change to the docker directory and build/run the container"
	cd "$DOCKER_TARGET_DIR"

	# build and run the sqlplus docker container
	echo "build and run the sqlplus docker container"
	docker compose -f docker-compose.yml up -d  --build

}

# function to shutdown the docker container and cleanup docker target folder
function shutdown_cleanup_docker_project ()
{

	echo "unset the CONFIG_DATA variable"
	# unset the CONFIG_DATA variable
	unset CONFIG_DATA


	# when the deployment has been completed, shutdown the container
	echo "shutdown the container"
 	docker compose down


	# remove the docker files in the target directory
	echo "remove the docker files in the target directory"
	rm -rf "$DOCKER_TARGET_DIR"

	echo "$CURRENT_SCRIPT_NAME has finished running"
}

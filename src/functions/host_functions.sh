#!/bin/bash

# function to initialize the docker target folder (where the docker project will be built/run) and build/run the container.  This function is run by the ${DOCKER_ACCOUNT_NAME} to build and run the container. This function accepts 2 parameters:
# 1: the full path to the docker source directory
# 2: the path of the docker compose file (relative to the docker source directory)
# Usage: 
# initialize_run_docker_project "/tmp/lhp-data-management-deploy/docker" "./docker-compose.yml"
function initialize_run_docker_project ()
{
 	echo "Change to the docker directory and build/run the container"

	local docker_host_container_source_path="$1"
	local docker_compose_file_path="$2"

	# input validation
    if [[ -z "$docker_host_container_source_path" || -z "$docker_compose_file_path" ]]; then
        echo "ERROR: shutdown_cleanup_docker_project() requires the full path to the docker source directory and the path to the docker compose file as arguments" >&2
        return 1
    fi

	# change to the docker container directory
	cd ${docker_host_container_source_path}

	# build and run the sqlplus docker container
	echo "build and run the sqlplus docker container"
	build_deploy_container ${docker_compose_file_path}
}

# function to shutdown the docker container and cleanup docker target folder after the container scripts have been executed. This function is run by the ${DOCKER_ACCOUNT_NAME} to build and run the container. This function accepts 2 parameters:
# 1: the name of the configuration data variable used to store the STDIN data
# 2: the path of the docker compose file (relative to the docker source directory - see docker_host_container_source_path in initialize_run_docker_project())
# Usage:
# shutdown_cleanup_docker_project "CONFIG_DATA" "./docker-compose.yml" 
function shutdown_cleanup_docker_project ()
{
	local config_data_var="$1"
	local docker_compose_file_path="$2"

	# input validation
    if [[ -z "$config_data_var" || -z "$docker_compose_file_path" ]]; then
        echo "ERROR: shutdown_cleanup_docker_project() requires the name of the configuration data variable and the path to the docker compose file as arguments" >&2
        return 1
    fi

	echo "shutdown the docker container and cleanup docker target folder"

	# unset the variable named $config_data_var
	unset_config_data "$config_data_var"

	# when the deployment has been completed, shutdown the container
 	shutdown_container ${docker_compose_file_path}
}


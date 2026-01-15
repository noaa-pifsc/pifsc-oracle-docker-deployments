#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container.  This function is run to build and run the container. This function accepts 2 parameters:
# 1: the full path to the container source directory
# 2: the path of the container compose file (relative to the container_database_deployment source directory)
# Example Usage:  
# initialize_run_container_project "/tmp/lhp-data-management-deploy/container_database_deployment" "./docker-compose.yml"
function initialize_run_container_project ()
{
 	echo "Change to the container directory and build/run the container"

	local CONTAINER_HOST_SOURCE_PATH="$1"
	local container_compose_file_path="$2"

	# input validation
    if [[ -z "$CONTAINER_HOST_SOURCE_PATH" || -z "$container_compose_file_path" ]]; then
        echo "ERROR: shutdown_cleanup_container_project() requires the full path to the container source directory and the path to the container compose file as arguments" >&2
        return 1
    fi

	# change to the container container directory
	cd ${CONTAINER_HOST_SOURCE_PATH}

	# build and run the sqlplus container
	echo "build and run the sqlplus container"
	build_deploy_container ${container_compose_file_path}
}

# function to shutdown the container and cleanup the container target folder after the container scripts have been executed. This function is run to shutdown the container. This function accepts 2 parameters:
# 1: the name of the configuration data variable used to store the STDIN data
# 2: the path of the container compose file (relative to the container_database_deployment source directory - see CONTAINER_HOST_SOURCE_PATH in initialize_run_container_project())
# Example Usage: 
# shutdown_cleanup_container_project "CONFIG_DATA" "./docker-compose.yml" 
function shutdown_cleanup_container_project ()
{
	local config_var_name="$1"
	local container_compose_file_path="$2"

	# input validation
    if [[ -z "$config_var_name" || -z "$container_compose_file_path" ]]; then
        echo "ERROR: shutdown_cleanup_container_project() requires the name of the configuration data variable and the path to the container compose file as arguments" >&2
        return 1
    fi

	echo "shutdown the container and cleanup the container target folder"

	# unset the variable named $config_var_name
	unset_config_data "$config_var_name"

	# when the deployment has been completed, shutdown the container
 	shutdown_container ${container_compose_file_path}
}


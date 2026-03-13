#! /bin/bash

# define a list of configuration variables that drive the behavior of the oracle container deployment scripts 

##### Container Host Configuration Variables: #####

	# define the container source directory that will be created on the container host by cloning the project repository
	CONTAINER_HOST_PROJECT_PATH="/tmp/${CONTAINER_PROJECT_FOLDER}"

	# define the container source directory that contains the container source files (e.g. Dockerfile, docker-compose.yml)
	CONTAINER_HOST_SOURCE_PATH="${CONTAINER_HOST_PROJECT_PATH}/container_database_deployment"

	# define the path to the folder where the host bash scripts are contained
	CONTAINER_HOST_SCRIPTS_PATH="${CONTAINER_HOST_PROJECT_PATH}/container_database_deployment/deployment_scripts/host_scripts"

	# declare a variable for the path of the container compose file
	CONTAINER_COMPOSE_FILE_PATH="${CONTAINER_BUILD_PATH}/docker-compose.yml"	
#! /bin/bash

# define a list of configuration variables that drive the behavior of the database container deployment scripts 

##### Container Host Configuration Variables: #####

	# define the container source directory that will be created on the container host by cloning the project repository
	HOST_SOURCE_PATH="/tmp/${CONTAINER_NAME}"

	# define the container source directory that contains the container source files (e.g. Dockerfile, docker-compose.yml)
	SOURCE_PATH="${HOST_SOURCE_PATH}/container_database_deployment"

	# define the path to the folder where the host bash scripts are contained
	HOST_SCRIPTS_PATH="${HOST_SOURCE_PATH}/container_database_deployment/deployment_scripts/host_scripts"

	# declare a variable for the path of the container compose file
	COMPOSE_PATH="${BUILD_PATH}/docker-compose.yml"	

	# define the name of the container image
	IMAGE_NAME="pifsc/${CONTAINER_NAME}:latest"
	
#! /bin/bash

# define a list of configuration variables that drive the behavior of the oracle container deployment scripts 

##### Container Configuration Variables: #####

	# define the container's root folder where the source files are copied
	ROOT_PATH="/usr/src/database_deploy"

	# define the path to the container's bash scripts folder
	CONTAINER_SCRIPTS_PATH="${ROOT_PATH}/container_database_deployment/deployment_scripts/container_scripts"

##### Container Project Configuration Variables: #####

	#declare a variable to store the name of the configuration data variable that is passed via STDIN that contains secret values
	SECRET_DATA_VAR_NAME="SECRET_DATA"

	#declare a variable to store the name of the associative array containing the secret names and corresponding bash variables
	SECRET_MAPPING_VAR_NAME="SECRET_MAPPING_ARR"
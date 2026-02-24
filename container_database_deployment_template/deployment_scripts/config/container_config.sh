#! /bin/bash

# define a list of configuration variables that drive the behavior of the oracle container deployment scripts 

##### Container Host Configuration Variables: #####

	# determine current folder path (container_database_deployment/deployment_scripts/config)
	CUSTOM_CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# determine where the designated container subfolder in the local filesystem is (/container_database_deployment):
	LOCAL_CONTAINER_BUILD_PATH="${CUSTOM_CONFIG_DIR}/../../"
	
	# determine where the repository root path based on the configuration file location
	REPO_ROOT_PATH="${CUSTOM_CONFIG_DIR}/../../../"

	# define the container source directory that will be created on the container host by cloning the project repository
	CONTAINER_HOST_PROJECT_PATH="/tmp/${CONTAINER_PROJECT_FOLDER}"

	# define the container source directory that contains the container source files (e.g. Dockerfile, docker-compose.yml)
	CONTAINER_HOST_SOURCE_PATH="${CONTAINER_HOST_PROJECT_PATH}/container_database_deployment"

	# define the path to the folder where the host bash scripts are contained
	CONTAINER_HOST_SCRIPTS_PATH="${CONTAINER_HOST_PROJECT_PATH}/container_database_deployment/deployment_scripts/host_scripts"

##### Container Configuration Variables: #####

	# define the deployment script logs folder
	DEPLOYMENT_SCRIPT_LOGS="${CUSTOM_CONFIG_DIR}/../../deployment_script_logs"	
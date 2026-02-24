#! /bin/bash

# define a list of configuration variables that drive the behavior of the oracle container deployment scripts 

##### Container Host Configuration Variables: #####

	# determine current folder path (container_database_deployment/deployment_scripts/config)
	CUSTOM_CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# determine where the designated container subfolder in the local filesystem is (/container_database_deployment):
	LOCAL_CONTAINER_BUILD_PATH="${CUSTOM_CONFIG_DIR}/../../"
	
	# determine where the repository root path based on the configuration file location
	REPO_ROOT_PATH="${CUSTOM_CONFIG_DIR}/../../../"

##### Container Configuration Variables: #####

	# define the container's root folder where the source files are copied
	CONTAINER_ROOT_PATH="/usr/src/database_deploy"

	# define the deployment script logs folder
	DEPLOYMENT_SCRIPT_LOGS="${CUSTOM_CONFIG_DIR}/../../deployment_script_logs"	

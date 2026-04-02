#! /bin/bash

# define a list of configuration variables that drive the behavior of the database container deployment scripts 

##### Container Host Configuration Variables: #####

	# determine current folder path (container_database_deployment/deployment_scripts/config)
	CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# determine where the designated container subfolder in the local filesystem is (/container_database_deployment):
	BUILD_PATH="${CONFIG_DIR}/../../"
	
	# determine where the repository root path based on the configuration file location
	REPO_ROOT_PATH="${CONFIG_DIR}/../../../"

##### Container Configuration Variables: #####

	# define the deployment script logs folder
	DEPLOYMENT_SCRIPT_LOGS="${CONFIG_DIR}/../../deployment_script_logs"	

	# define the container scripts path based on the configuration file's path
	LOCAL_CONTAINER_SCRIPTS_PATH="${CONFIG_DIR}/../container_scripts"	
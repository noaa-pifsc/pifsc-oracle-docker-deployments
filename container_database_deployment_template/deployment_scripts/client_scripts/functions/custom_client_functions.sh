#!/bin/bash

# function that initializes the ENV_NAME variable and loads the client secret/configuration files, and process the $config_data_var_name so it can be passed to a bash script via STDIN
# this function accepts the following parameters: 
# 1: (optional) the environment name (dev, test, prod)
# 2: (optional) deployment destination (local, server)
# 3: (optional) script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
function execute_deployment ()
{
	# set the environment and deployment destination variable values
	set_env_deployment_vars "${1}" "${2}"
	
	# set the script type variable value
	set_script_type_var "${3}"
	
	# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
	local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# change directory into the container_database_deployment folder that contains the Dockerfile and .yml files (/container_database_deployment)
	cd "${LOCAL_CONTAINER_BUILD_PATH}"

	# validate that the corresponding container script exists:
	if [ ! -f "${curr_dir}/../../container_scripts/container_${SCRIPT_TYPE}.sh" ]; then
		echo "ERROR: the script type definition (script type: ${SCRIPT_TYPE}) argument's corresponding container deployment file does not exist: $curr_dir/../../container_scripts/container_${SCRIPT_TYPE}.sh"
		return 1
	fi

	# recursively convert the line endings for all .sh files in the root folder of the repository (/)
	convert_dos2unix "${curr_dir}/../../../../"

	# load the bash variables for the runtime configuration (/container_database_deployment/deployment_scripts/config)
	source "${curr_dir}/../../config/deploy_config.${ENV_NAME}.sh"
	
	# load the oracle credentials into bash variables (/container_database_deployment/secrets/$ENV_NAME)
	source "${curr_dir}/../../../secrets/${ENV_NAME}/secrets.sh"

	# process the configuration data
	process_config_data "${SECRET_MAPPING_VAR_NAME}" "${CONFIG_DATA_VAR_NAME}"
	
	# prepare and execute the corresponding deployment script:
	prepare_execute_deployment_script "${ENV_NAME}" "${DEPLOY_DEST}" "${CONTAINER_HOSTNAME}" "${CONTAINER_HOST_PROJECT_PATH}" "${CONTAINER_GIT_URL}" "${CONFIG_DATA_VAR_NAME}" "${CONTAINER_HOST_SCRIPTS_PATH}" "${LOCAL_CONTAINER_BUILD_PATH}" "${CONTAINER_COMPOSE_FILE_PATH}" "${SCRIPT_TYPE}" "${DB_HOST}" "${DB_SERVICE_NAME}" "${SECRET_MAPPING_VAR_NAME}"	"${CONTAINER_SCRIPTS_PATH}"
}
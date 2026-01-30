#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "${0}")")"

# include the host functions
source ./includes/include_host_resources.sh

# initialize the container environment variables
initialize_container_env_var "${0}"

# initialize the container target folder and build/run the container
host_deploy_container_elev_privs "${CONTAINER_HOST_SOURCE_PATH}" "${CONTAINER_COMPOSE_FILE_PATH}"

# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $CONFIG_DATA_VAR_NAME
process_stdin_config_data "${SECRET_MAPPING_VAR_NAME}" "${CONFIG_DATA_VAR_NAME}"

# execute the scripts from within the container
execute_container_script "${CONTAINER_SCRIPTS_PATH}" "${CONTAINER_COMPOSE_FILE_PATH}" "${CONFIG_DATA_VAR_NAME}" "$(host_deploy_define_env_vars_block)"

#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "${0}")")"

# include the host functions
source ./includes/include_host_resources.sh

# initialize the container environment variables
initialize_container_env_var "${0}"

# convert the line endings for all .sh and .env files in the parent folder
convert_dos2unix "../../../"

# process the stdin configuration data: parse and store in variables, construct the formatted CONFIG_DATA variable
process_stdin_config_data "${SECRET_MAPPING_VAR_NAME}" "${CONFIG_DATA_VAR_NAME}"

# build/run the container
build_run_container "${CONTAINER_HOST_PROJECT_PATH}" "${CONTAINER_ACCOUNT_NAME}" "${CONTAINER_HOST_SCRIPTS_PATH}" "${CONFIG_DATA_VAR_NAME}"

#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the host functions
source ./functions/host_functions.sh
source ./functions/custom_host_functions.sh
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# initialize the docker target folder and build/run the container
initialize_run_docker_project

# read the key/value pairs from STDIN and store them in bash variables
parse_config_data

# echo "connect to the docker container, run the ${SCRIPT_TYPE} script"

# encode the configuration variable data:
CONFIG_DATA=$(encode_config_data)
# echo "the value of CONFIG_DATA is: $CONFIG_DATA"

# construct the full path to the script that will be executed within the container:
SCRIPT_PATH="/usr/src/oracle_deploy/container_scripts/container_${SCRIPT_TYPE}.sh"

# unset bash variables specified by STDIN
unset_config_variables

# open a bash session into the running container and run the appropriate container deployment script (based on $SCRIPT_TYPE) and provide the $CONFIG_DATA via stdin
cat <<EOF | docker exec -i lhp_oracle_deploy bash -c $SCRIPT_PATH
$CONFIG_DATA
EOF

# shutdown and cleanup the docker project
shutdown_cleanup_docker_project

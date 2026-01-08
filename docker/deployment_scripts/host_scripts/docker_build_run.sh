#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the host functions
source ./includes/include_host_resources.sh

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
SCRIPT_PATH="/usr/src/oracle_deploy/deployment_scripts/container_scripts/container_${SCRIPT_TYPE}.sh"

# unset bash variables specified by STDIN
unset_config_variables

echo "run the container_${SCRIPT_TYPE}.sh script from within the container to execute the corresponding automated scripts"


# open a bash session into the running container and run the appropriate container deployment script (based on $SCRIPT_TYPE) and provide the $CONFIG_DATA via stdin
cat <<EOF | docker exec -i oracle_deploy bash -c "
    # specify the environment variables that are defined in the calling script:
    export DB_HOST='$DB_HOST'
    export DB_SERVICE_NAME='$DB_SERVICE_NAME'
    export ENV_NAME='$ENV_NAME'
    # Execute the target script, which will inherit the variables above.
    bash '$SCRIPT_PATH'
"
$CONFIG_DATA
EOF

# shutdown and cleanup the docker project
shutdown_cleanup_docker_project

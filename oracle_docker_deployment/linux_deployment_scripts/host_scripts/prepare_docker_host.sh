#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the host functions
source ../shared_functions/shared_functions.sh
source ./functions/host_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# convert the line endings for all .sh and .env files in the parent folder
convert_dos2unix "../"

# create the docker source directory
mkdir -p "$DOCKER_SOURCE_DIR"

# clone the git project to the designated docker source directory folder
git clone $DOCKER_GIT_URL "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"

# convert all .sh and .env files in the repository to unix line endings
convert_dos2unix "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"

echo "$CURRENT_SCRIPT_NAME has finished running"

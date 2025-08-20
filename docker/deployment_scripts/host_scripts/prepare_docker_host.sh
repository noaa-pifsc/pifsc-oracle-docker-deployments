#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the host functions
source ../shared_functions/shared_functions.sh
source ./functions/host_functions.sh
source ./functions/custom_host_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# convert the line endings for all .sh and .env files in the parent folder
convert_dos2unix "../"

echo "prepare the source files within the docker preparation folder"

# prepare the docker preparation folder
prepare_docker_prep_folder

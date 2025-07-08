#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"


# include the shell script functions
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh
source ./functions/host_functions.sh

# initialize the docker environment variables
initialize_docker_env_var "$0"

# initialize the docker source folder
initialize_docker_source_folder

# process the stdin configuration data: parse and store in variables, construct the
# process_stdin_config_data

# read the key/value pairs from STDIN and store them in bash variables
parse_config_data

# encode the configuration variable data:
CONFIG_DATA=$(encode_config_data)

# unset bash variables specified by STDIN
unset_config_variables

# define the absolute path to the deployment script that will run as docker-user.
SCRIPT_PATH="${DOCKER_SOURCE_DIR}/${DOCKER_GIT_DIR}/oracle_docker_deployment/linux_deployment_scripts/host_scripts/docker_build_run.sh"

# Run the deployment script and pass in the key/value pairs stored in $CONFIG_DATA to stdin.
# The outer heredoc (<<EOF) sends commands to 'sudo su - docker-user'.
# This command chain works passwordless due to specific sudoers configuration:
# 1. 'sudo su - docker-user': Allowed via 'NOPASSWD: /bin/su - docker-user' in sudoers.
# 2. Bypasses 'Defaults requiretty': This specific nested heredoc structure
#    was designed to bypass sudo's 'requiretty' setting in non-interactive contexts,
#    which would otherwise demand a terminal and cause the script to fail.
# The inner heredoc (cat <<'CREDEND') passes CONFIG_DATA literally to the target script.
# Single quotes around 'CREDEND' (e.g., 'CREDEND') are critical. They prevent Bash
# from performing variable expansion, command substitution, or backslash escaping
# on the \$CONFIG_DATA content, ensuring that special characters (like literal '$')
# are preserved exactly as defined.
sudo su - docker-user <<EOF
cat <<'CREDEND' | bash "$SCRIPT_PATH"
$CONFIG_DATA
CREDEND
EOF

# cleanup the docker source folder
cleanup_docker_source_folder

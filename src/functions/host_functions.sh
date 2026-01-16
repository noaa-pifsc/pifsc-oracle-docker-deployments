#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container.  This function is run to build and run the container. This function accepts 2 parameters:
# 1: the full path to the container source directory
# 2: the path of the container compose file (relative to the container_database_deployment source directory)
# Example Usage:  
# initialize_run_container_project "/tmp/lhp-data-management-deploy/container_database_deployment" "./docker-compose.yml"
function initialize_run_container_project ()
{
 	echo "Change to the container directory and build/run the container"

	local container_host_source_path="${1}"
	local container_compose_file_path="${2}"

	# input validation
    if [[ -z "${container_host_source_path}" || -z "${container_compose_file_path}" ]]; then
        echo "ERROR: shutdown_cleanup_container_project() requires the full path to the container source directory and the path to the container compose file as arguments" >&2
        return 1
    fi

	# change to the container container directory
	cd "${container_host_source_path}"

	# build and run the sqlplus container
	echo "build and run the sqlplus container"
	build_deploy_container "${container_compose_file_path}"
}

# function to shutdown the container and cleanup the container target folder after the container scripts have been executed. This function is run to shutdown the container. This function accepts 2 parameters:
# 1: the name of the configuration data variable used to store the STDIN data
# 2: the path of the container compose file (relative to the container_database_deployment source directory - see CONTAINER_HOST_SOURCE_PATH in initialize_run_container_project())
# Example Usage: 
# shutdown_cleanup_container_project "CONFIG_DATA" "./docker-compose.yml" 
function shutdown_cleanup_container_project ()
{
	local config_data_var_name="${1}"
	local container_compose_file_path="${2}"

	# input validation
    if [[ -z "${config_data_var_name}" || -z "${container_compose_file_path}" ]]; then
        echo "ERROR: shutdown_cleanup_container_project() requires the name of the configuration data variable and the path to the container compose file as arguments" >&2
        return 1
    fi

	echo "shutdown the container and cleanup the container target folder"

	# unset the variable named $config_data_var_name
	unset_config_data "${config_data_var_name}"

	# when the deployment has been completed, shutdown the container
 	shutdown_container "${container_compose_file_path}"
}


# function to build/run the container using the ${container_account_name} account. This function accepts the following parameters:
# 1: the container source directory on the container host
# 2: the name of a container privileged user account that can run container commands
# 3: the path to the folder where the host bash scripts are contained  
# 4: name of the configuration data variable
function build_run_container ()
{
	local container_host_project_path="${1}"
	local container_account_name="${2}"
	local container_host_scripts_path="${3}"
	local config_data_var_name="${4}"

	if [[ -z "${container_host_project_path}" || -z "${container_account_name}" || -z "${container_host_scripts_path}" || -z "${config_data_var_name}" ]]; then
        echo "ERROR: build_run_container() requires the container source directory on the container host, the name of a container privileged user account that can run container commands, the path to the folder where the host bash scripts are contained, and the name of the configuration data variable as arguments" >&2
        return 1
    fi

	# define the absolute path to the deployment script that will run as ${container_account_name}.
	local script_path="${container_host_project_path}/container_build_run.sh"
	
	echo "build and run the container with the container user account"

# Run the deployment script and pass in the key/value pairs stored in $CONFIG_DATA to stdin.
# The outer heredoc (<<EOF) sends commands to 'sudo su - ${container_account_name}'.
# This command chain works passwordless due to specific sudoers configuration:
# 1. 'sudo su - ${container_account_name}': Allowed via 'NOPASSWD: /bin/su - ${container_account_name}' in sudoers.
# 2. Bypasses 'Defaults requiretty': This specific nested heredoc structure
#    was designed to bypass sudo's 'requiretty' setting in non-interactive contexts,
#    which would otherwise demand a terminal and cause the script to fail.
# The inner heredoc (cat <<'CREDEND') passes CONFIG_DATA literally to the target script.
# Single quotes around 'CREDEND' (e.g., 'CREDEND') are critical. They prevent Bash
# from performing variable expansion, command substitution, or backslash escaping
# on the \$CONFIG_DATA content, ensuring that special characters (like literal '$')
# are preserved exactly as defined.
# set the environment variable values 
sudo su - ${container_account_name} <<EOF
# Set the environment variables in the new shell.
export SCRIPT_TYPE="${SCRIPT_TYPE}"
export DB_HOST="${DB_HOST}"
export DB_SERVICE_NAME="${DB_SERVICE_NAME}"
export ENV_NAME='${ENV_NAME}'
cat <<'CREDEND' | bash "${script_path}"
${!config_data_var_name}
CREDEND
EOF

	# cleanup the container source folder
	cleanup_container_source_folder "${container_host_project_path}" "${config_data_var_name}"
}


# function to run the oracle database scripts within the running container. This function accepts the following parameters:
# 1: the path to the container's bash scripts folder
# 2: the path of the container compose file
# 3: name of the configuration data variable
function execute_container_scripts ()
{
	local container_scripts_path="${1}"
	local container_compose_file_path="${2}"
	local config_data_var_name="${3}"

	if [[ -z "${container_scripts_path}" || -z "${container_compose_file_path}" || -z "${config_data_var_name}" ]]; then
        echo "ERROR: execute_container_scripts() requires the path to the container's bash scripts folder, the path of the container compose file, and the name of the configuration data variable as arguments" >&2
        return 1
    fi

	# construct the full path to the script that will be executed within the container:
	local script_path="${container_scripts_path}/container_${SCRIPT_TYPE}.sh"

	echo "run the container_${SCRIPT_TYPE}.sh script from within the container to execute the corresponding automated scripts"

# open a bash session into the running container and run the appropriate container deployment script (based on $SCRIPT_TYPE) and provide the value of the variable identified by $config_data_var_name via stdin
docker exec -i oracle_deploy bash -c "
	# specify the environment variables that are defined in the calling script:
	export SCRIPT_TYPE='${SCRIPT_TYPE}'
	export DB_HOST='${DB_HOST}'
	export DB_SERVICE_NAME='${DB_SERVICE_NAME}'
	export ENV_NAME='${ENV_NAME}'
	# Execute the target script, which will inherit the variables above.
	bash '${script_path}'
" <<< "${!config_data_var_name}"

	# shutdown and cleanup the container project
	shutdown_cleanup_container_project "${config_data_var_name}" "${container_compose_file_path}"
}

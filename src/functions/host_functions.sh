#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container using an account with elevated privileges.  This function is run to build and run the container. This function accepts 2 parameters:
# 1: the full path to the container source directory
# 2: the path of the container compose file (relative to the container_database_deployment source directory)
# Example Usage:  
# host_deploy_container_elev_privs "/tmp/lhp-data-management-deploy/container_database_deployment" "./docker-compose.yml"
function host_deploy_container_elev_privs ()
{
 	echo "Change to the container directory and build/run the container"

	local container_host_source_path="${1}"
	local container_compose_file_path="${2}"

	# input validation
    if [[ -z "${container_host_source_path}" || -z "${container_compose_file_path}" ]]; then
        echo "ERROR: host_deploy_container_elev_privs() requires the full path to the container source directory and the path to the container compose file as arguments" >&2
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
# 2: the path of the container compose file (relative to the container_database_deployment source directory - see CONTAINER_HOST_SOURCE_PATH in host_deploy_container_elev_privs())
# Example Usage: 
# host_shutdown_container_elev_privs "CONFIG_DATA" "./docker-compose.yml" 
function host_shutdown_container_elev_privs ()
{
	local config_data_var_name="${1}"
	local container_compose_file_path="${2}"

	# input validation
    if [[ -z "${config_data_var_name}" || -z "${container_compose_file_path}" ]]; then
        echo "ERROR: host_shutdown_container_elev_privs() requires the name of the configuration data variable and the path to the container compose file as arguments" >&2
        return 1
    fi

	echo "shutdown the container and cleanup the container target folder"

	# unset the variable named $config_data_var_name
	unset_config_data "${config_data_var_name}"

	# when the deployment has been completed, shutdown the container
 	shutdown_container "${container_compose_file_path}"
}

# function to run the oracle database scripts within the running container. This function accepts the following parameters:
# 1: the full path of the calling script
# 2: the path to the container's bash scripts folder
# 3: the path of the container compose file
# 4: name of the configuration data variable
# 5: the full path to the container source directory
# 6: the name of the associative array containing the secret names and corresponding bash variables
# 7: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
function host_execute_container_script ()
{
	local current_script_name="${1}"
	local container_scripts_path="${2}"
	local container_compose_file_path="${3}"
	local config_data_var_name="${4}"
	local container_host_source_path="${5}"
	local secret_mapping_var_name="${6}"
	local env_vars_block="${7:-}"

	if [[ -z "${current_script_name}" || -z "${container_scripts_path}" || -z "${container_compose_file_path}" || -z "${config_data_var_name}" || -z "${container_host_source_path}" || -z "${secret_mapping_var_name}" ]]; then
        echo "ERROR: host_execute_container_script() requires the full path of the calling script, the path to the container's bash scripts folder, the path of the container compose file, the name of the configuration data variable, the full path to the container source directory, the name of the associative array containing the secret names and corresponding bash variables as arguments" >&2
        return 1
    fi

	# initialize the container environment variables
	initialize_container_env_var "${current_script_name}"

	# initialize the container target folder and build/run the container
	host_deploy_container_elev_privs "${container_host_source_path}" "${container_compose_file_path}"

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $config_data_var_name
	process_stdin_config_data "${secret_mapping_var_name}" "${config_data_var_name}"

	# construct the full path to the script that will be executed within the container:
	local script_path="${container_scripts_path}/container_${SCRIPT_TYPE}.sh"

	echo "run the container_${SCRIPT_TYPE}.sh script from within the container to execute the corresponding automated scripts"

# open a bash session into the running container and run the appropriate container deployment script (based on $SCRIPT_TYPE) and provide the value of the variable identified by $config_data_var_name via stdin
docker exec -i oracle_deploy bash -c "
	# specify the environment variables that are defined in the calling script:
	${env_vars_block}
	
	# Execute the target script, which will inherit the variables above.
	bash '${script_path}'
" <<< "${!config_data_var_name}"

	# shutdown and cleanup the container project
	host_shutdown_container_elev_privs "${config_data_var_name}" "${container_compose_file_path}"
}



# function to initialize and run the database deployment container on the host machine. This function accepts the following parameters:
# 1: the full path of the calling script
# 2: the repository root folder (used to convert all .sh files to use linux-style line endings for compatibility purposes
# 3: the name of the associative array containing the secret names and corresponding bash variables
# 4: name of the configuration data variable
# 5: the container source directory on the container host
# 6: the name of a container privileged user account that can run container commands
# 7: the path to the folder where the host bash scripts are contained
# 8: name of the host script that is executed to deploy the container
# 9: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
function host_deploy_container ()
{
	local current_script_name="${1}"
	local parent_root_folder="${2}"
	local secret_mapping_var_name="${3}"
	local config_data_var_name="${4}"
	local container_host_project_path="${5}"
	local container_account_name="${6}"
	local container_host_scripts_path="${7}"
	local host_script_name="${8}"
	local env_vars_block="${9}"

	# input validation
    if [[ -z "${current_script_name}" || -z "${parent_root_folder}" || -z "${secret_mapping_var_name}" || -z "${config_data_var_name}" || -z "${container_host_project_path}" || -z "${container_account_name}" || -z "${container_host_scripts_path}" || -z "${host_script_name}" ]]; then
        echo "ERROR: host_initialize_deploy_container() requires the full path of the calling script, the repository root folder, the name of the associative array containing the secret names and corresponding bash variables, the name of the configuration data variable, the container source directory on the container host, the name of a container privileged user account that can run container commands, the path to the folder where the host bash scripts are contained, and name of the host script that is executed to deploy the container as arguments" >&2
        return 1
    fi

	# initialize the container environment variables
	initialize_container_env_var "${current_script_name}"

	# convert the line endings for all .sh and .env files in the parent folder
	convert_dos2unix "../../../"

	# process the stdin configuration data: parse and store in variables, construct the formatted CONFIG_DATA variable
	process_stdin_config_data "${secret_mapping_var_name}" "${config_data_var_name}"

	# build/run the container
	# define the absolute path to the deployment script that will run as ${container_account_name}.
	local script_path="${container_host_scripts_path}/${host_script_name}"
	
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
${env_vars_block}

cat <<'CREDEND' | bash "${script_path}"
${!config_data_var_name}
CREDEND
EOF

	# cleanup the container source folder
	cleanup_container_source_folder "${container_host_project_path}" "${config_data_var_name}"
}
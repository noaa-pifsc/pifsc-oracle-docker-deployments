#!/bin/bash

# function to initialize the container target folder (where the container project will be built/run) and build/run the container using an account with elevated privileges.  This function is run to build and run the container.  
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_host_source_path: the full path to the container source directory
# container_compose_file_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_mapping_var_name: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_data_var_name: name of the configuration data variable
# current_script_name: the full path of the calling script
function host_deploy_container_elev_privs ()
{
	# store the function array argument
	local arg_array="${1}"

	# input validation
    if [[ -z "$(get_array_val "${arg_array}" "container_host_source_path")" || -z "$(get_array_val "${arg_array}" "container_compose_file_path")" || -z "$(get_array_val "${arg_array}" "secret_mapping_var_name")" || -z "$(get_array_val "${arg_array}" "config_data_var_name")" || -z "$(get_array_val "${arg_array}" "current_script_name")" ]]; then
        echo "ERROR: host_deploy_container_elev_privs() requires the full path to the container source directory, the path to the container compose file, the name of the configuration data variable, the name of an associative array that maps the secret values passed to bash commands via STDIN, and the full path of the calling script as arguments" >&2
        return 1
    fi

	# initialize the container environment variables
	initialize_container_env_var "$(get_array_val "${arg_array}" "current_script_name")"

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $config_data_var_name
	process_stdin_config_data "$(get_array_val "${arg_array}" "secret_mapping_var_name")" "$(get_array_val "${arg_array}" "config_data_var_name")"

	# change to the container container directory
	cd "$(get_array_val "${arg_array}" "container_host_source_path")"

	# build and run the sqlplus container
	echo "build and run the sqlplus container"
	build_deploy_container_compose "$(get_array_val "${arg_array}" "container_compose_file_path")"
}

# function to deploy the database container and execute the container script
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# container_host_source_path: the full path to the container source directory
# container_compose_file_path: the path of the container compose file (relative to the container_database_deployment source directory)
# secret_mapping_var_name: the name of an associative array that maps the secret values passed to bash commands via STDIN
# config_data_var_name: name of the configuration data variable
# current_script_name: the full path of the calling script
# container_scripts_path: the path to the container's bash scripts folder
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
function host_deploy_database_execute_container_script()
{
	# store the function array argument
	local arg_array="${1}"

	# input validation
    if [[ -z "$(get_array_val "${arg_array}" "container_host_source_path")" || -z "$(get_array_val "${arg_array}" "container_compose_file_path")" || -z "$(get_array_val "${arg_array}" "secret_mapping_var_name")" || -z "$(get_array_val "${arg_array}" "config_data_var_name")" || -z "$(get_array_val "${arg_array}" "current_script_name")" || -z "$(get_array_val "${arg_array}" "container_scripts_path")" ]]; then
        echo "ERROR: host_deploy_database_execute_container_script() requires the full path to the container source directory, the path to the container compose file, the name of the configuration data variable, the name of an associative array that maps the secret values passed to bash commands via STDIN, the full path of the calling script, and the path to the container's bash scripts folder as arguments" >&2
        return 1
    fi

	# declare the function arguments
	local -A DEPLOY_FUNC_ARGS=(
			["current_script_name"]="$(get_array_val "${arg_array}" "current_script_name")"
			["container_host_source_path"]="$(get_array_val "${arg_array}" "container_host_source_path")"
			["container_compose_file_path"]="$(get_array_val "${arg_array}" "container_compose_file_path")"
			["config_data_var_name"]="$(get_array_val "${arg_array}" "config_data_var_name")"
			["secret_mapping_var_name"]="$(get_array_val "${arg_array}" "secret_mapping_var_name")"
		)

	# deploy the container to the host server
	host_deploy_container_elev_privs "DEPLOY_FUNC_ARGS"
	
	# declare the function arguments
	local -A EXEC_FUNC_ARGS=(
			["container_scripts_path"]="$(get_array_val "${arg_array}" "container_scripts_path")"
			["container_compose_file_path"]="$(get_array_val "${arg_array}" "container_compose_file_path")"
			["config_data_var_name"]="$(get_array_val "${arg_array}" "config_data_var_name")"
			["env_vars_block"]="$(get_array_val "${arg_array}" "env_vars_block")"
		)

	# execute the container script 
	execute_container_script "EXEC_FUNC_ARGS"
}

# function to initialize and run the database deployment container on the host machine. This function accepts the following parameters as elements in the specified array name (arg_array):
# current_script_name: the full path of the calling script
# parent_root_folder: the repository root folder (used to convert all .sh files to use linux-style line endings for compatibility purposes)
# secret_mapping_var_name: the name of the associative array containing the secret names and corresponding bash variables
# config_data_var_name: name of the configuration data variable
# container_host_project_path: the container source directory on the container host
# container_account_name: the name of a container privileged user account that can run container commands
# container_host_scripts_path: the path to the folder where the host bash scripts are contained
# host_script_name: name of the host script that is executed to deploy the container
# env_vars_block: (optional) a formatted list of custom export commands that will precede the bash script call to define any environment variables that are necessary for the bash script
function host_deploy_container ()
{
	# store the function array argument
	local arg_array="${1}"

	# input validation
    if [[ -z $(get_array_val "${arg_array}" "current_script_name") || -z $(get_array_val "${arg_array}" "parent_root_folder") || -z $(get_array_val "${arg_array}" "secret_mapping_var_name") || -z $(get_array_val "${arg_array}" "config_data_var_name") || -z $(get_array_val "${arg_array}" "container_host_project_path") || -z $(get_array_val "${arg_array}" "container_account_name") || -z $(get_array_val "${arg_array}" "container_host_scripts_path") || -z $(get_array_val "${arg_array}" "host_script_name") ]]; then
        echo "ERROR: host_deploy_container() requires the full path of the calling script, the repository root folder, the name of the associative array containing the secret names and corresponding bash variables, the name of the configuration data variable, the container source directory on the container host, the name of a container privileged user account that can run container commands, the path to the folder where the host bash scripts are contained, and name of the host script that is executed to deploy the container as arguments" >&2
        return 1
    fi

	# initialize the container environment variables
	initialize_container_env_var $(get_array_val "${arg_array}" "current_script_name")

	# convert the line endings for all .sh and .env files in the parent folder
	convert_dos2unix $(get_array_val "${arg_array}" "parent_root_folder")

	# process the stdin configuration data: parse and store in variables, construct the formatted CONFIG_DATA variable
	process_stdin_config_data $(get_array_val "${arg_array}" "secret_mapping_var_name") $(get_array_val "${arg_array}" "config_data_var_name")

	# build/run the container
	# define the absolute path to the deployment script that will run as ${container_account_name}.
	local script_path=$(get_array_val "${arg_array}" "container_host_scripts_path")"/"$(get_array_val "${arg_array}" "host_script_name")
	
	# store the values of the variables used in the sudo su call into local variables
	local env_vars_block=$(get_array_val "${arg_array}" "env_vars_block")
	local config_data_var_name=$(get_array_val "${arg_array}" "config_data_var_name")

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
sudo su - $(get_array_val "${arg_array}" "container_account_name") <<EOF
# Set the environment variables in the new shell.
${env_vars_block}

cat <<'CREDEND' | bash "${script_path}"
${!config_data_var_name}
CREDEND
EOF

	# cleanup the container source folder
	cleanup_container_source_folder $(get_array_val "${arg_array}" "container_host_project_path") $(get_array_val "${arg_array}" "config_data_var_name")
}
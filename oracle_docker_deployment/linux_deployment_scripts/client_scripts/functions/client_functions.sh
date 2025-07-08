#!/bin/bash



# this function initializes the client deployment scripts
# this function accepts 1 parameter: the full script path name that was executed
# Usage:
#   initialize_deployment_script "$0"
function initialize_deployment_script
{

	# retrieve the current script name that was originally invoked
	get_script_name_from_path "$1"

	# create the client logfile
	create_logfile $CURRENT_SCRIPT_NAME

}


# this function prepares and executes the client deployment scripts
# this function accepts 2 parameters: the environment name (dev, qa, prod), and the ssh username used to connect to the remote docker host
# Usage:
#   prepare_deployment_script "$1" "$2"
function prepare_execute_deployment_script ()
{
	local passed_env_name="$1"
	local passed_ssh_user="$2"

	# save/prompt for environment name and ssh username variables
	set_env_and_user_vars "$passed_env_name" "$passed_ssh_user"

#	echo "The value of ENV_NAME is: $ENV_NAME"

	# convert all the .sh files in the parent directory to unix line endings
	convert_dos2unix "../"

	# load the bash variables for the runtime configuration
	source ../config/deploy_config.$ENV_NAME.sh
	source ../config/docker_host_config.sh

	# Prepare the docker host by creating directories and cloning the repository
	prepare_docker_host

	# Transfer any special files
	transfer_special_files

	# load the oracle credentials into bash variables
	source ../../docker/container_scripts/config/oracle_credentials.$ENV_NAME.sh

	# compile stdin credential/configuration variables:
	CONFIG_DATA=$(encode_config_data)

	# unset the sensitive bash variables so they can't be reused
	unset_config_variables

	# execute the deployment/upgrade script on the host server and specify the bash variable values as stdin
	exec_remote_cmd_with_stdin "$CONFIG_DATA" "bash $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR/oracle_docker_deployment/linux_deployment_scripts/host_scripts/initiate_docker.sh"

	# unset the CONFIG_DATA now that the plink call has completed
	unset CONFIG_DATA

	read -p "The $CURRENT_SCRIPT_NAME script finished executing, press Enter to exit"

}





# function that initializes the ENV_NAME and DOCKER_USERNAME variables for use in the script.
# this function accepts two optional parameters: the environment name (dev, qa, prod) and the ssh username used to connect to the remote docker host
# Usage:
#   set_env_and_user "$1" "$2"
#   or with no arguments to trigger prompts:
#   set_env_and_user
function set_env_and_user_vars() {
  local passed_env_name="$1"
  local passed_ssh_user="$2"

#	echo "running set_env_and_user_vars($1, $2)"

  # Set ENV_NAME from argument or prompt the user
  if [[ -n "$passed_env_name" ]]; then
    ENV_NAME="$passed_env_name"
  else

	# prompt the user for an environment value
	read -rp "Enter environment (dev, qa, prod): " ENV_NAME < /dev/tty

# 	echo "The value of ENV_NAME is: $ENV_NAME"

  fi

  # Validate that ENV_NAME is one of the accepted values
  case "$ENV_NAME" in
    dev|qa|prod) ;;
    *)
      echo "ERROR: Invalid environment name '$ENV_NAME'. Must be one of: dev, qa, prod."
      exit 1
      ;;
  esac

	# construct the path to the appropriate oracle_credentials.sh file
  local oracle_credentials_path="../../docker/container_scripts/config/oracle_credentials.$ENV_NAME.sh"

  if [[ ! -f "$oracle_credentials_path" ]]; then
	echo "ERROR: Required file '$oracle_credentials_path' not found.  Exiting script"
	exit 1
  fi


  # Set DOCKER_USERNAME from argument or prompt the user
  if [[ -n "$passed_ssh_user" ]]; then
    DOCKER_USERNAME="$passed_ssh_user"
  else

    read -rp "Enter SSH username: " DOCKER_USERNAME < /dev/tty
# 	echo "The value of DOCKER_USERNAME is: '$DOCKER_USERNAME'"

  fi
}

# function that creates a logfile and populates it with all output from the script
# this function accepts one parameter, the logfile prefix
# Usage:
#   create_logfile "$1"
function create_logfile ()
{
	# store the log file prefix in a local variable
	local passed_logfile_prefix="$1"

	# create the logfile with a date/time suffix
	LOGFILE="../../deployment_script_logs/$passed_logfile_prefix.$(date +%Y%m%d_%H%M%S).log"
	exec > >(tee -a "$LOGFILE") 2>&1
}


# function that prepares the docker host by creating the temporary directory structure, copying the initial .sh and .env files for the host and executes the prepare_docker_host.sh script.  This function accepts no parameters
# Usage:
# prepare_docker_host
function prepare_docker_host ()
{
	echo "create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts"

	# create the directory path ('$DOCKER_SOURCE_DIR') for the initial deployment scripts
	exec_remote_cmd "mkdir -p '$DOCKER_SOURCE_DIR' && ls -l '$DOCKER_SOURCE_DIR'"

	# copy the bash scripts and .env files to the remote server
	echo "copy all bash scripts and config files to the remote server"
	transfer_files "../../linux_deployment_scripts" "$DOCKER_SOURCE_DIR"

	# execute the prepare_docker_host.sh script on the host server
	echo "execute the prepare_docker_host.sh script on the host server"
	exec_remote_cmd "bash $DOCKER_SOURCE_DIR/linux_deployment_scripts/host_scripts/prepare_docker_host.sh"
}


# function that transfers any special files to the host server (when applicable), this is meant to be changed for a given database/APEX implementation.  This function accepts no parameters
# Usage:
# transfer_special_files
function transfer_special_files()
{
#	echo "running transfer_special_files()"

	# copy the custom DB data backup file to the docker host
	echo "copy the custom DB data backup file to the docker host"
	transfer_files ../../SQL/queries/PIC_LIFEHIST_table_data_export20250617.sql "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/SQL/queries

}



# function to execute a remote command/script using plink
# The function accepts one parameter: the command to be executed
# Usage:
# exec_remote_cmd "$1"
function exec_remote_cmd ()
{
	# store the command parameter in a local variable
	local passed_cmd="$1"

	echo "running exec_remote_cmd ($1)"

# echo "plink $DOCKER_USERNAME@$DOCKER_HOSTNAME $passed_cmd"
	# execute the command via plink
	plink "$DOCKER_USERNAME"@"$DOCKER_HOSTNAME" "$passed_cmd"

}


# function to execute a remote command/script using plink and pass values in via STDIN
# The function accepts two parameters: the STDIN value and the command to be executed
# Usage:
# exec_remote_cmd_with_stdin "$1" "$2"
function exec_remote_cmd_with_stdin ()
{
	# store the command parameter in a local variable
	local passed_stdin_content="$1"
	local passed_cmd="$2"

	echo "running exec_remote_cmd ($2)"

# echo "plink $DOCKER_USERNAME@$DOCKER_HOSTNAME $passed_cmd"
	# execute the command via plink
	echo "$passed_stdin_content" | plink "$DOCKER_USERNAME"@"$DOCKER_HOSTNAME" "$passed_cmd"

}


# function to transfer files to/from the remote host:
# the first parameter is the source directory/file
# the second parameter is the target directory/file
# Usage:
# transfer_files "$1" "$2"
function transfer_files ()
{
#	echo "running transfer_files ($1, $2)"

	# store the parameters in local variables
	local passed_source="$1"
	local passed_target="$2"

#	echo "pscp $passed_source $DOCKER_USERNAME@$DOCKER_HOSTNAME:$passed_target"

	# transfer folder/files from passed_source to passed_target using pscp
	pscp -r $passed_source "$DOCKER_USERNAME"@"$DOCKER_HOSTNAME":$passed_target
}

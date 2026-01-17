#!/bin/bash

# this function initializes the SCRIPT_TYPE variable for use in the script.
# this function accepts an optional parameter: the script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# Example Usage:  
#   set_script_type_var "$1"
#   or with no arguments to trigger prompts:
#   set_script_type_var
function set_script_type_var ()
{
    # Calls the helper with its specific parameters
    set_validated_var \
        "SCRIPT_TYPE" \
        "Enter destination (name of the database deployment script type with the suggested naming convention of (deploy|upgrade|rollback)_version[0-9]+\.[0-9]+)" \
        "[a-zA-Z0-9_\.]+" \
        "the name of container script with the naming convention container_[SCRIPT_TYPE].sh" \
        "${1}"
}


# this function prepares and executes the client deployment scripts
# this function accepts the following parameters: 
# 1: (optional) the environment name (dev, test, prod)
# 2: (optional) deployment destination (local, server)
# 3: container hostname to connect to
# 4: the container source directory on the container host
# 5: git url for the container project's repository
# 6: name of the configuration data variable
# 7: the path to the folder where the host bash scripts are contained
# 8: the local container build folder path (/container_database_deployment)
# 9: the path of the container compose file (relative to the container build folder path)
# 10: the script type (e.g. deploy_version2.0, upgrade_version1.8, rollback_version1.6) 
# 11: the database hostname
# 12: the database service name
# 13: the name of the associative array containing the secret names and corresponding bash variables
# 14: the path to the container's bash scripts folder
# Example Usage:
#   prepare_execute_deployment_script "$1" "$2" "$3" "docker-server-as1" "/tmp/lhp-data-management-deploy" "git@github.com:example-repo.git" "CONFIG_DATA" "/tmp/lhp-data-management-deploy/container_database_deployment/host_scripts" "/c/Users/USERNAME/lhp-data-management/container_database_deployment" "./docker-compose.yml" "deploy_version2.0" "oracle-db-host" "oracle-db-servicename" "SECRET_MAPPING_ARR"
function prepare_execute_deployment_script ()
{
	echo "prepare the container source files and deploy the container"
	
	local env_name="${1}"
	local deployment_destination="${2}"
	local container_hostname="${3}"
	local container_host_project_path="${4}"
	local container_git_url="${5}"
	local config_data_var_name="${6}"
	local container_host_scripts_path="${7}"
	local local_container_build_path="${8}"
	local container_compose_file_path="${9}"
	local script_type="${10}"
	local db_host="${11}"
	local db_service_name="${12}"
	local SECRET_MAPPING_VAR_NAME="${13}"
	local container_scripts_path="${14}"
	
	# input validation
    if [[ -z "${env_name}" || -z "${deployment_destination}" || -z "${container_hostname}" || -z "${container_host_project_path}" || -z "${container_git_url}" || -z "${config_data_var_name}" || -z "${container_host_scripts_path}" || -z "${local_container_build_path}" || -z "${container_compose_file_path}" || -z "${script_type}" || -z "${db_host}" || -z "${db_service_name}" || -z "${SECRET_MAPPING_VAR_NAME}" || -z "${container_scripts_path}" ]]; then
        echo "ERROR: prepare_execute_deployment_script() requires the environment name, the deployment destination, the container hostname to connect to, the container source directory on the container host, git url for the container project's repository, name of the configuration data variable, the path to the folder where the host bash scripts are contained, the local container build folder path (/container_database_deployment), the path of the container compose file (relative to the container build folder path), the script type, the database host, the database service name, the name of an associative array that maps the secret values passed to bash commands via STDIN, and the path to the container's bash scripts folder as arguments" >&2
        return 1
    fi

	# Check if the DEPLOY_DEST variable is "server" 
	if [[ "${deployment_destination}" == "server" ]]; then
		# Prepare the container host by cloning the project repository
		prepare_container_host "${container_hostname}" "${container_host_project_path}" "${container_git_url}"

		# execute the container deployment script on the host server and specify the sensitive values as stdin and the configuration values as environment variables
		exec_remote_cmd_with_stdin "${container_hostname}" "${!config_data_var_name}" "SCRIPT_TYPE=\"${script_type}\" DB_HOST=\"${db_host}\" DB_SERVICE_NAME=\"${db_service_name}\" ENV_NAME=\"${env_name}\" bash ${container_host_scripts_path}/initiate_container.sh"

		# unset the configuration now that the ssh call has completed
		unset_config_data "${config_data_var_name}"

	else
		# this is a local deployment scenario:
		
		# determine current folder path (/container_database_deployment/deployment_scripts/client_scripts/functions)
		local curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

		# change directory into the container folder that contains the Dockerfile and .yml files (/container_database_deployment)
		cd "${local_container_build_path}"

		# this is a mounted directory deployment
		echo "deploy the container with container compose for development purposes"

		# stop and remove any running container and build/run the container from the source code
		build_deploy_container "${container_compose_file_path}"

		# execute the corresponding container scripts and shutdown the container
		execute_container_scripts "${container_scripts_path}" "${container_compose_file_path}" "${config_data_var_name}"

		echo "the local container deployment script has finished executing"

	fi
}

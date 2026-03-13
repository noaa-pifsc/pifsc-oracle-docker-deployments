#!/bin/bash

#-----------------------------------------------------------------------------
# shared_functions.sh:
# this file defines shared functions that are used for this specific 
# container application for container deployments
#-----------------------------------------------------------------------------

# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# Accepts 2 parameters: 
# 1: the environment name
# 2: the script type
function proj_shared_define_env_vars_block()
{
	local env_name="${1}"
	local script_type="${2}"

	# echo the strictly local runtime variables natively
	echo "export CONTAINER_ENV_NAME='${env_name}'"
	echo "export CONTAINER_SCRIPT_TYPE='${script_type}'"
	
	# use the dynamic generator for the global project configuration constants
	cds_shared_generate_export_env_vars_block "DB_HOST" "DB_SERVICE_NAME"
}

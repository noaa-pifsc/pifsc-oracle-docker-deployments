#!/bin/bash

#-----------------------------------------------------------------------------
# custom_shared_functions.sh:
# this file defines custom shared functions that are used for this specific 
# container application for container deployments
#-----------------------------------------------------------------------------

# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# this function accepts no parameters
function host_deploy_define_env_vars_block()
{
	# build the list of environment variable declarations passed to the bash script, in multi-line format for readability. Expand variables before it is passed to the bash function
	local env_vars_block="
	export ENV_NAME='${ENV_NAME}'
	export SCRIPT_TYPE='${SCRIPT_TYPE}'
	export DB_HOST='${DB_HOST}'
	export DB_SERVICE_NAME='${DB_SERVICE_NAME}'
	"

	# return the multiline string
	echo "${env_vars_block}"
}

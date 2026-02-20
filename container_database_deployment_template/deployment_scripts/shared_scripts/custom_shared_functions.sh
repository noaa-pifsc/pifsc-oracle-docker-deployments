#!/bin/bash

#-----------------------------------------------------------------------------
# custom_shared_functions.sh:
# this file defines custom shared functions that are used for this specific 
# container application for container deployments
#-----------------------------------------------------------------------------

# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# this function accepts no parameters
function define_env_vars_block()
{

	######## Environment Variable Block Placeholder - START ########
	# construct a string with each bash variable to be passed to the bash script that is being executed on the host or container, each variable declaration should be on a separate line for readability purposes.

	# Example:
	# 	local env_vars_block="
	# export CONTAINER_ENV_NAME='${CONTAINER_ENV_NAME}'
	# export SCRIPT_TYPE='${SCRIPT_TYPE}'
	# export DB_HOST='${DB_HOST}'
	# export DB_SERVICE_NAME='${DB_SERVICE_NAME}'
	# "

	######## Environment Variable Block Placeholder - END ########

	# return the multiline string
	echo "${env_vars_block}"
}

#!/bin/bash

#-----------------------------------------------------------------------------
# custom_shared_functions.sh:
# this file defines custom shared functions that are used for this specific 
# container application for container deployments
#-----------------------------------------------------------------------------

# function that defines the environment variable bash block that will define the environment variables for inclusion when the build/run container bash scripts execute
# this function accepts no parameters
function proj_shared_define_env_vars_block()
{

	######## Environment Variable Block Placeholder - START ########
	# build the list of environment variable declarations passed to the bash script, in multi-line format for readability.
	
	# Example: 
	# cds_shared_generate_export_env_vars_block "CONTAINER_ENV_NAME" "CONTAINER_SCRIPT_TYPE" "DB_HOST" "DB_SERVICE_NAME"

	######## Environment Variable Block Placeholder - END ########
}

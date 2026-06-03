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
	local ENV_NAME="${1}"
	local SCRIPT_TYPE="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"ENV_NAME" "SCRIPT_TYPE"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# use the dynamic generator for the global project configuration constants
	cds_shared_generate_export_env_vars_block "DB_HOST" "DB_SERVICE_NAME" "ENV_NAME" "SCRIPT_TYPE"
}

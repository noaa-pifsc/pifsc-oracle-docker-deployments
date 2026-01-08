#!/bin/bash

# this function initializes the DEPLOY_DEST variable for use in the script.
# this function accepts an optional parameter: the deployment destination (local, server) 
# Usage: 
#   set_dest_var "$1"
#   or with no arguments to trigger prompts:
#   set_dest_var
function set_dest_var ()
{
    # Calls the helper with its specific parameters
    set_validated_var \
        "DEPLOY_DEST" \
        "Enter destination (local, server)" \
        "local|server" \
        "local, server" \
        "$1"
}

# function to set the ENV_NAME and DEPLOY_DEST global variables so they can be used to determine the behavior of the docker deployment scripts
function set_env_deployment_vars ()
{
	local env_name="$1"
	local deployment_destination="$2"

	# save/prompt for environment name
	set_env_var "$env_name" 
	
	# save/prompt for deployment destination
	set_dest_var "$deployment_destination"
}
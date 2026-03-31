#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_database.sh:
# this host script runs a script as the $PRIV_USER to build the 
# container image and run the container on the container host by executing 
# host_deploy_database_elev_privs.sh
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# initialize and build/run the container on the host machine with the specified function arguments:
proj_host_deploy_container
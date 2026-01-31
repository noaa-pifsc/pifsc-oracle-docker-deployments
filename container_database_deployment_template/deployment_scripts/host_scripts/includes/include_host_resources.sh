#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the host
# container deployment scripts (intended for remote container host scenarios)
#-----------------------------------------------------------------------------

# determine current folder path (container_database_deployment/deployment_scripts/host_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the container configuration variables
source "${CURR_DIR}/../../config/custom_container_config.sh"

# include the custom shared function definitions
source "${CURR_DIR}/../../shared_scripts/custom_shared_functions.sh"

# include the CDD/CDS shared/hostfunctions
source "${CURR_DIR}/../../../../modules/CDD/src/includes/load_CDD_host_resources.sh"
#!/bin/bash

#-----------------------------------------------------------------------------
# include_client_resources.sh:
# this file loads all of the reusable bash files that are used in the client 
# container deployment scripts (intended for remote container host scenarios)
#-----------------------------------------------------------------------------

# determine current folder path (container_database_deployment/deployment_scripts/client_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load the environment variables
source "${CURR_DIR}/../../../.env"

# include the CDD/CDS shared/client functions
source "${CURR_DIR}/../../../../modules/CDD/src/includes/load_CDD_client_resources.sh"

# include the container configuration variables
source "${CURR_DIR}/../../config/custom_container_config.sh"
source "${CURR_DIR}/../../config/container_config.sh"

# include the custom shared function definitions
source "${CURR_DIR}/../../shared_scripts/custom_shared_functions.sh"

# include the client functions
source "${CURR_DIR}/../functions/custom_client_functions.sh"
source "${CURR_DIR}/../functions/client_functions.sh"


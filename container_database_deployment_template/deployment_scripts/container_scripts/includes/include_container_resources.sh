#!/bin/bash

#-----------------------------------------------------------------------------
# include_container_resources.sh:
# this file loads all of the reusable bash files that are used in the container
# container deployment scripts (intended for remote container host scenarios)
#-----------------------------------------------------------------------------

# determine current folder path (container_database_deployment/deployment_scripts/container_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load the environment variables
source "${CURR_DIR}/../../../.env"

# include the CDD/CDS shared/container functions
source "${CURR_DIR}/../../../../modules/CDD/src/includes/load_CDD_container_resources.sh"

# include the container configuration variables
source "${CURR_DIR}/../../config/initial_container_config.sh"
source "${CURR_DIR}/../../config/custom_container_config.sh"
source "${CURR_DIR}/../../config/container_config.sh"

# include the container functions
source "${CURR_DIR}/../functions/custom_container_functions.sh"
source "${CURR_DIR}/../functions/container_functions.sh"
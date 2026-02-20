#!/bin/bash

# this file includes the CDD and CDS host functions so the path to the CDS functions does not need to be known by projects that implement CDD as a submodule

# determine current folder path (CDD/src/includes)
CDD_INCL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# source the CDD host/shared functions
source "${CDD_INCL_DIR}/../functions/CDD_host_functions.sh"
source "${CDD_INCL_DIR}/../functions/CDD_shared_functions.sh"

# source the CDD configuration
source "${CDD_INCL_DIR}/../config/container_config.sh"

# determine CDS submodule root folder (CDD/modules/CDS)
CDS_DIR="${CDD_INCL_DIR}/../../modules/CDS"

# source the nested CDS submodule client/shared functions
source "${CDS_DIR}/src/CDS_shared_functions.sh"
source "${CDS_DIR}/src/CDS_host_functions.sh"
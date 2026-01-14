#!/bin/bash

# this file includes the CDD and CDS client functions so the path to the CDS functions does not need to be known by projects that implement CDD as a submodule

# determine current folder path (CDD/src/includes)
CDD_INCL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# determine CDS submodule root folder (CDD/modules/CDS)
CDS_DIR="$CDD_INCL_DIR/../../modules/CDS"

# source the nested CDS submodule client/shared functions
source "$CDS_DIR/src/shared_functions.sh"
source "$CDS_DIR/src/local_client_functions.sh"
source "$CDS_DIR/src/client_functions.sh"
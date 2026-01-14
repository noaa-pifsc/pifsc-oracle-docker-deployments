#!/bin/bash

# this file includes the ODD and CDS host functions so the path to the CDS functions does not need to be known by projects that implement ODD as a submodule

# determine current folder path (ODD/src/includes)
ODD_INCL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# source the ODD host functions
source "$ODD_INCL_DIR/../functions/host_functions.sh"

# determine CDS submodule root folder (ODD/modules/CDS)
CDS_DIR="$ODD_INCL_DIR/../../modules/CDS"

# source the nested CDS submodule client/shared functions
source "$CDS_DIR/src/shared_functions.sh"
source "$CDS_DIR/src/host_functions.sh"
#!/bin/bash
set -euo pipefail

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include shell script function definitions
source ../shared_functions/shared_functions.sh
source ../shared_functions/custom_shared_functions.sh
source ./functions/client_functions.sh
source ./functions/custom_client_functions.sh

# initialize the deployment script
initialize_deployment_script "$0"

# notify the user which script is being run
echo "***********************************************************************"
echo "********* Executing [DB_NAME] version x.x DB/APEX deployment script *********"
echo "***********************************************************************"
echo "*Note: This script will deploy version x.x of the [DB_NAME] database and APEX app to a blank database schema"
echo ""

# define the type of script
SCRIPT_TYPE="deploy_versionx.x"

# prepare and execute the deployment script
prepare_execute_deployment_script "${1:-}" "${2:-}"

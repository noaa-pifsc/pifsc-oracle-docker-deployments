#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the container functions
source ./functions/container_functions.sh
source ./functions/custom_container_functions.sh
source ./functions/shared_functions.sh
source ./functions/custom_shared_functions.sh

# initialize the container
initialize_container_script "$0"

echo "deploy version x.x of the DB"

sqlplus -s /nolog <<EOF
@./automated_deployments/deploy_${ENV_NAME}_db_vx.x.sql ${DB_CONN_STRING}
EOF

echo "deploy version x.x of the apex app"

sqlplus -s /nolog <<EOF
@./automated_deployments/deploy_apex_${ENV_NAME}_vx.x.sql ${DB_APP_CONN_STRING}
EOF

# cleanup the container variables now that the script has finished running
cleanup_container_variables

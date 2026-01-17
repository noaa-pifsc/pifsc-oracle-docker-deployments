#!/bin/bash

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"

# include the container functions
source ./includes/include_container_resources.sh

# initialize the container
initialize_container "${0}" "${CONTAINER_ROOT_SQL_PATH}" "${SECRET_MAPPING_VAR_NAME}"

echo "deploy version 2.0 of the DB"

# deploy version 2.0 of the DB
sqlplus -s /nolog <<EOF
@./automated_deployments/deploy_${ENV_NAME}_db_v2.0.sql ${DB_CONN_STRING}
EOF

echo "load the production data"

# load the production data
sqlplus -s /nolog <<EOF
CONNECT ${DB_CONN_STRING}
@queries/special/clone_data_from_production_pt1.sql
@queries/special/clone_data_from_production_pt2.sql
EOF


echo "deploy version 2.0 of the apex app"

sqlplus -s /nolog <<EOF
@./automated_deployments/deploy_apex_${ENV_NAME}_v2.0.sql ${DB_APP_CONN_STRING}
EOF

# cleanup the container variables now that the script has finished running
cleanup_container "${SECRET_MAPPING_VAR_NAME}"

echo "The deployment script finished running"
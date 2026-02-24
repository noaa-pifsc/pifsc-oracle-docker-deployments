#!/bin/bash

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_container_resources.sh"

# initialize the container
container_initialize "${0}" "${CONTAINER_ROOT_SQL_PATH}" "${SECRET_MAPPING_VAR_NAME}"

######## Container Database Deployment Placeholder - START ########

# Example for version 2.0 of the DB:

# echo "deploy version 2.0 of the DB"

# deploy version 2.0 of the DB
#sqlplus -s /nolog <<EOF
#@./automated_deployments/deploy_${CONTAINER_ENV_NAME}_db_v2.0.sql ${DB_CONN_STRING}
# EOF


# Example for version 2.0 of the apex app:

# echo "deploy version 2.0 of the apex app"

# sqlplus -s /nolog <<EOF
# @./automated_deployments/deploy_apex_${CONTAINER_ENV_NAME}_v2.0.sql ${DB_APP_CONN_STRING}
# EOF

######## Container Database Deployment Placeholder - END ########

# cleanup the container variables now that the script has finished running
container_cleanup "${SECRET_MAPPING_VAR_NAME}"

echo "The deployment script finished running"
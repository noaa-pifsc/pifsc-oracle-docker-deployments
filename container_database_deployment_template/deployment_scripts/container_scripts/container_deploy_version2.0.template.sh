#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_container_resources.sh"


# main function to execute the database scripts from within the container with local variable scope for sensitive information
function main()
{

######## Container Database Deployment Placeholder - START ########

	# declare local variables to store the constructed database connection strings
	local DB_CONN_STRING=""
	local DB_APP_CONN_STRING=""

	# initialize the container and securely pass the local SECURE_SECRETS_ARR array to be populated with the parsed secret variables
	proj_container_initialize "${0}" "${CONTAINER_ROOT_SQL_PATH}" "${SECRET_MAPPING_VAR_NAME}" "SECURE_SECRETS_ARR" "DB_CONN_STRING" "DB_APP_CONN_STRING" || return 1

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

	# cleanup the container variables now that the script has finished running
	proj_container_cleanup "${SECRET_MAPPING_VAR_NAME}"

######## Container Database Deployment Placeholder - END ########

	echo "The deployment script finished running"
}

# execute the main function
main "$@"
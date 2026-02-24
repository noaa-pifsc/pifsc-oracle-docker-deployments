#! /bin/bash

# define a list of configuration variables that drive the behavior of the oracle container deployment scripts 

##### Container Host Configuration Variables: #####

	# container privileged user account that can run container commands
	# Example: CONTAINER_ACCOUNT_NAME="docker-user"
	CONTAINER_ACCOUNT_NAME="[CONTAINER_ACCOUNT_NAME]"

	# declare a variable for the path of the container compose file
	# Example: CONTAINER_COMPOSE_FILE_PATH="docker-compose.yml"
	CONTAINER_COMPOSE_FILE_PATH="[CONTAINER_COMPOSE_FILE_PATH]"

	# define the project folder name
	# Example: CONTAINER_PROJECT_FOLDER="my-project-name"
	CONTAINER_PROJECT_FOLDER="[CONTAINER_PROJECT_FOLDER]"

	# define the container git project URL
	# Example: CONTAINER_GIT_URL="git@github.com/my-great-organization/my-great-project.git"
	CONTAINER_GIT_URL="[CONTAINER_GIT_URL]"

##### Container Configuration Variables: #####

	# define the container's root SQL folder where the sqlplus commands will be sent from
	# Example: CONTAINER_ROOT_SQL_PATH="${CONTAINER_ROOT_PATH}/SQL"
	CONTAINER_ROOT_SQL_PATH="[CONTAINER_ROOT_SQL_PATH]"

##### Container Project Configuration Variables: #####

	# declare an associative array with the secret name as the array element and the bash variable name as the array value, in the array element names (e.g. "Container Secret Name") must be unique, but do not have a specific function in the CDD, but the element values must correspond to the bash variable names in the corresponding secrets.sh file for the database credentials to be provided to the SQLPlus scripts successfully

	# Example:
	declare -A SECRET_MAPPING_ARR=(
		# [Container Secret Name] = "Bash Variable Name"
		["db_username_secret"]="ORACLE_DB_USER"
		["db_password_secret"]="ORACLE_DB_PASS"
		["app_username_secret"]="ORACLE_DB_APP_USER"
		["app_password_secret"]="ORACLE_DB_APP_PASS"
	)

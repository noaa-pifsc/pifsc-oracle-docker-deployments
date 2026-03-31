#! /bin/bash

# define a list of configuration variables that drive the behavior of the oracle container deployment scripts 

##### Container Host Configuration Variables: #####

	# container privileged user account that can run container commands
	# Example: PRIV_USER="docker-user"
	PRIV_USER="[CONTAINER_ACCOUNT_NAME]"

	# define the project folder name
	# Example: PROJECT_FOLDER="my-project-name"
	PROJECT_FOLDER="[PROJECT_FOLDER]"

	# define the container git project URL
	# Example: GIT_URL="git@github.com/my-great-organization/my-great-project.git"
	GIT_URL="[GIT_URL]"

	# define the name of the container image
	# Example: IMAGE_NAME="pifsc/pifsc-project-name:latest"
	IMAGE_NAME="[IMAGE_NAME]"

##### Container Configuration Variables: #####

	# define the container's root SQL folder where the sqlplus commands will be sent from
	# Example: CONTAINER_SQL_PATH="${CONTAINER_ROOT_PATH}/SQL"
	CONTAINER_SQL_PATH="[CONTAINER_SQL_PATH]"

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

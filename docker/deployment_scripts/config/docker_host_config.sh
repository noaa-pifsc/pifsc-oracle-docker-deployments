#! /bin/bash

# docker user account
DOCKER_ACCOUNT_NAME="docker-user"

# define the project folder name
PROJECT_FOLDER="[PROJECT NAME]"


DOCKER_SOURCE_DIR="/tmp/$PROJECT_FOLDER"

DOCKER_TARGET_DIR="/home/$DOCKER_ACCOUNT_NAME/containers/$PROJECT_FOLDER"

DOCKER_GIT_URL="[GIT URL]"

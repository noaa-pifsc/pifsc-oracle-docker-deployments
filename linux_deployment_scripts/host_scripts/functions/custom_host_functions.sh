#!/bin/bash


# function to copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
# Usage:
# prepare_docker_target_dir
function prepare_docker_target_dir ()
{

	# sync files to docker source directory:
	echo "Copy the ${DOCKER_SOURCE_DIR}/${DOCKER_GIT_DIR} source files to the destination directory: ${DOCKER_TARGET_DIR}"
	rsync -a "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/docker/* "$DOCKER_TARGET_DIR"
	rsync -a "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/SQL "$DOCKER_TARGET_DIR"/src
	rsync -a "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/application_code "$DOCKER_TARGET_DIR"/src
	rsync -a "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/docs/location_hierarchy "$DOCKER_TARGET_DIR"/src/docs

	# move the container_scripts into the src directory
	mv "$DOCKER_TARGET_DIR"/container_scripts "$DOCKER_TARGET_DIR/src/"

	# copy the shared functions so they are available for the container scripts
	rsync -a "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/linux_deployment_scripts/shared_functions/* "$DOCKER_TARGET_DIR/src/container_scripts/functions"
}

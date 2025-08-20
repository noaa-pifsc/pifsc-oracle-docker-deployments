#!/bin/bash


# function to copy the necessary files to deploy/upgrade/rollback a specific data system from the $DOCKER_SOURCE_DIR/$DOCKER_GIT_DIR to the $DOCKER_TARGET_DIR
# Usage:
# prepare_docker_target_dir
function prepare_docker_target_dir ()
{
	# copy project-specific files into the corresponding directories within the $DOCKER_TARGET_DIR:
	rsync -a "$DOCKER_SOURCE_DIR"/docker/* "$DOCKER_TARGET_DIR"

}




# function to prepare the docker preparation folder that will be copied to 
function prepare_docker_prep_folder ()
{
	# copy project-specific files from the $DOCKER_SOURCE_DIR into the corresponding directories within the $DOCKER_TARGET_DIR:
		
	#################################################
	######## Project-Specific Code Goes Here ########
	#################################################
}

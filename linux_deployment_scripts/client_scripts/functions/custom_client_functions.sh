#!/bin/bash

# this file contains custom client functions used for specific data systems


# function that transfers any special files to the host server (when applicable), this is meant to be changed for a given database/APEX implementation.  This function accepts no parameters
# Usage:
# transfer_special_files
function transfer_special_files()
{
#	echo "running transfer_special_files()"

	# copy the custom DB data backup file to the docker host
	echo "copy the custom DB data backup file to the docker host"
	transfer_files ../../SQL/queries/PIC_LIFEHIST_table_data_export20250617.sql "$DOCKER_SOURCE_DIR"/"$DOCKER_GIT_DIR"/SQL/queries

}

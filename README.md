# PIFSC Oracle Docker Deployment Process

## Overview
When the PIFSC Oracle data center was moved to the cloud it was no longer feasible to deploy/upgrade/rollback databases and APEX applications directly from local workstations via the PIFSC network connection.  In an effort to automate the process and move it closer to the database/application servers the Oracle Docker Deployment Process (ODP) was developed.  The ODP can be executed by running a single script on the local client that will execute a series of commands.  This project can be used as a basis to implement the automated process for a specific Oracle data system

## Prerequisites
-   Remote docker host running in OCI that has connectivity to the corresponding OCI database instance
    -   dos2unix
-   git
-   PuTTY
    -   PuTTY secure copy client (Pscp) - a file transfer utility
    -   PuTTY Link (Plink) - a command line connection tool to execute commands on a given remote docker host
-   Windows/Linux machine with bash installed serving as the local client

## Resources
-   ODP Version Control Information:
    -   URL: https://github.com/noaa-pifsc/pifsc-oracle-docker-deployments
		-   Version 1.0 (git tag: pifsc_oracle_docker_deployment_v1.0)
-   [Docker Oracle Deployment Diagram](./diagrams/docker_oracle_deployment_diagram.drawio.png)
    -   [Docker Oracle Deployment Diagram Source File](./diagrams/docker_oracle_deployment_diagram.drawio)

## Prerequisites
-   The git database/app project must have automated SQLPlus scripts to deploy/upgrade/rollback the database/app
    -   The given schema(s) on the target database instance must be in the correct state for the desired script to run (e.g. blank database for new deployments, required database version for upgrades/rollbacks, etc.)
    -   If there are different versions of the automated SQLPlus scripts for the different environments (development, QA, production) they must incorporate the corresponding environment abbreviation (dev, qa, prod) in the script name so the appropriate script can be run for each environment (e.g. deploy_apex_qa_v1.5.sql for deploying version 1.5 of the APEX app to the qa environment)

## Data System Deployment Process Implementation Procedure
-   \*Note: A working example of this Deployment Process for an Oracle/APEX data system is available in the [LHP data system](https://picgitlab.nmfs.local/lhp/lhp-data-management) ([Documentation](https://picgitlab.nmfs.local/lhp/lhp-data-management/-/blob/master/docs/cloud%20docker%20deployment/LHP%20-%20Cloud%20Docker%20Deployment%20Method.md?ref_type=heads)).
-   Copy the following files/folders from this project repository to the root folder of the data system repository the automated deployment method is being implemented in:
    -   [linux_deployment_scripts](./linux_deployment_scripts)
        -   [client_scripts](./linux_deployment_scripts/client_scripts)
            -   [functions](./linux_deployment_scripts/client_scripts/functions)
                -   [custom_client_functions.sh](./linux_deployment_scripts/client_scripts/functions/custom_client_functions.sh):
                    -   transfer_special_files(): Update to transfer any special files that are not managed within the repository (if applicable).  
                        -   \*Note: if there are no special files that need to be transferred then this function body can be blank
            -   (multiple files based on the defined use cases) create a bash script for each use case intended to run on the client machine
                -   Example: [deploy_versionx.x.sh](./linux_deployment_scripts/client_scripts/deploy_versionx.x.sh) for deploying version x.x of the corresponding database to a blank database schema and version x.x of the APEX app
                -   Ensure that the SCRIPT_TYPE variable value matches the naming convention of the corresponding container script (e.g. [container_deploy_versionx.x.sh](./docker/container_scripts/container_deploy_versionx.x.sh) for SCRIPT_TYPE="deploy_versionx.x")
								-   Replace all instances of [DB_NAME] with the corresponding database name and remove "APEX" if the given data system does not include APEX
								-   \*Note: The main difference between the different use case bash scripts is informing the user which use case is being processed (via echo statements) and setting the $SCRIPT_TYPE variable value (e.g. deploy_version2.0)
        -   [host_scripts](./linux_deployment_scripts/host_scripts)
            -   [functions](./linux_deployment_scripts/host_scripts/functions):
                -   [custom_host_functions.sh](./linux_deployment_scripts/host_scripts/functions/custom_host_functions.sh):
                    -   prepare_docker_target_dir(): update to copy the directories/files from the corresponding project repository into the folder that will be used to build and run the docker container
        -   config
            -   docker_host_config.sh: update to define each of the bash variables for the docker host configuration
            -   deploy_config.${ENV_NAME}.sh: update to define the corresponding docker hostnames for each environment (dev, qa, prod)
        -   shared_functions
            -   custom_shared_functions.sh:
                -   parse_config_data(): update to include all the corresponding bash variables passed in by stdin
                    -   *\*Note:* when docker secrets has been implemented the scripts can be switched to using environment variables for SCRIPT_TYPE and ENV_NAME and remove this function
                -   encode_config_data(): update to include all the corresponding bash variables passed in by stdin
                    -   *\*Note:* when docker secrets has been implemented the scripts can be switched to using environment variables for SCRIPT_TYPE and ENV_NAME and remove this function
                -   unset_config_variables(): update to unset all bash variables passed in via stdin
                    -   *\*Note:* when docker secrets has been implemented the scripts can be switched to using environment variables for SCRIPT_TYPE and ENV_NAME and remove this function
    -   docker
        -   docker-compose.yml:
            -   Update the image and container name appropriately
        -   container_scripts:
            -   config:
                -   oracle_credentials.template.sh:
                    -   Update the template to define the appropriate bash variables necessary to execute the SQLPlus scripts on the corresponding database instance
            -   functions:
                -   [custom_container_functions.sh](../docker/container_scripts/functions/custom_container_functions.sh):
                    -   generate_connection_strings(): Update to construct the Oracle connection strings for each database schema that will have SQLPlus scripts executed
                    -   unset_connection_strings(): Update to unset the connection string variables defined in generate_connection_strings()
            -   (multiple files based on the defined use cases) create a bash script for each use case intended to run in the container to execute SQLPlus scripts on the specified database instance
                -   Example: [container_deploy_versionx.x.sh](./docker/container_scripts/container_deploy_versionx.x.sh) for deploying version x.x of the database to a blank database schema and version x.x of the APEX app
                -   \*Note: If there are different versions of the automated SQLPlus scripts for the different environments include the ${ENV_NAME} value in the SQLPlus script filename references to ensure the appropriate SQLPlus script is executed
    -   deployment_script_logs
        -   \*Note: the log files for the client script executions will be saved in this directory
		-   .gitignore
				-   \*Note: this file prevents dev, qa, and prod oracle credentials from being saved in the data system's repository

## Setup/Configuration
-   clone the given git data system project to a directory on the local client computer
-   Create the database connection information using the docker/container_scripts/config/oracle_credentials.template.sh file
    -   Make a copy of oracle_credentials.template.sh file within the docker/container_scripts/config folder and rename it to the corresponding OCI environment that the DB/APEX app will be depoyed to (e.g. oracle_credentials.qa.sh for the QA/test OCI environment)
        -   Specify the OCI database connection information and save the file
        -   \*Note: the actual configuration files should not be committed to the repository for security purposes, add a .gitignore file has been added to the repository to prevent these files from being included in git.  

## Executing the Appropriate Docker Oracle Deployment Script
-   \*Note: The [Docker Oracle Deployment Diagram](./diagrams/docker_oracle_deployment_diagram.drawio.png) provides an overview of the steps associated with the automated client script
-   Execute the specific bash script in the [client_scripts](../linux_deployment_scripts/client_scripts) folder for the corresponding use case
    -   For example, the [deploy_versionx.x.sh](./linux_deployment_scripts/client_scripts/deploy_versionx.x.sh) will deploy version x.x of the corresponding DB and APEX app to the specific OCI database instance
    -   (shown as step 1 in the diagram) The corresponding client script will prompt the user for the following information:
        -   OCI Environment (dev, qa, prod):
            -   This value is saved in $ENV_NAME and provided to subsequent scripts to inform their behavior based on the OCI environment
        -   Docker Username:
             -   This value is used in all subsequent pscp and plink calls to the docker host
        -   A log file for each client script execution is saved in [deployment_script_logs](./deployment_script_logs) and is named $SCRIPT_TYPE.$(date +%Y%m%d_%H%M%S).log based on the date/time the script is executed.  This file will include the output from the remote host and container scripts
    -   (shown as step 2 in the diagram) The client script will create a directory, copy the local [linux_deployment_scripts](./linux_deployment_scripts) folder to the remote docker host, and executes the [prepare_docker_host.sh](./linux_deployment_scripts/host_scripts/prepare_docker_host.sh) on the docker host via plink.
        -   When prepare_docker_host.sh runs on the remote host it clones the git repository ($DOCKER_GIT_URL) to the designated source directory ($DOCKER_SOURCE_DIR)
        -   The client script copies any special files to the remote host via pscp
        -   (show as step 3 in the diagram) The client script executes the [initiate_docker.sh](../linux_deployment_scripts/host_scripts/initiate_docker.sh) on the docker host via plink
        -   When initiate_docker.sh runs on the remote host it changes the permissions on the designated source directory to allow the docker-user account (this is the designated account to build/run containers) to read the files.
            -   (show as step 4 in the diagram) The [docker_build_run.sh](../linux_deployment_scripts/host_scripts/docker_build_run.sh) script is executed as docker-user on the remote host
                -   The script copies the necessary files into the designated directory ($DOCKER_TARGET_DIR) and builds/runs the container
                -   (show as step 5 in the diagram) The script executes a bash script within the running container (container_$SCRIPT_TYPE.sh - e.g. [container_deploy_version2.0.sh](../docker/container_scripts/container_deploy_version2.0.sh) for the use case that deploys version 2.0 of the database and APEX app to a blank database) and provides the $ENV_NAME as an argument.
                    -   (show as step 6 in the diagram) The bash container script runs a series of SQLPlus scripts that are managed within the corresponding data system repository that perform the processes on the database based on the use case and OCI environment.  
                -   When the container script finishes executing the container is shutdown and the docker files are removed from $DOCKER_TARGET_DIR
            -   The docker source files are removed from $DOCKER_SOURCE_DIR

## License
See the [LICENSE.md](./LICENSE.md) for details

## Disclaimer
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.

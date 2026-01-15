# PIFSC Container Database Deployment Process

## Overview
When the PIFSC Oracle data center was moved to the cloud it was no longer feasible to deploy/upgrade/rollback databases and APEX applications directly from local workstations via the PIFSC network connection.  In an effort to automate the process and move it closer to the database/application servers the Container Database Deployment (CDD) project was developed.  The CDD can be executed by running a single script on the local client that will execute a series of commands.  This project can be implemented as a submodule in any database system repository to implement the automated deployment process.

## Resources
-   CDD Version Control Information:
    -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments
    -   Version 1.2 (git tag: pifsc_oracle_docker_deployment_v1.2)
-   [Docker Oracle Deployment Diagram](./diagrams/container_database_deployment_diagram.drawio.png)
    -   [Docker Oracle Deployment Diagram Source File](./diagrams/container_database_deployment_diagram.drawio)

## Platform Requirements
-   Remote docker host running in OCI that has connectivity to the corresponding OCI database instance
    -   Docker
    -   dos2unix
    -   git
-   Windows/Linux machine serving as the local client
    -   Git Bash
    -   OpenSSH is setup to work with CAC authentication
    -   OpenSSH is configured to specify the username in the ~/.ssh/config file for each docker host (e.g. pifsc-dev-docker-01-as for the dev docker host)
        -   The ForwardAgent feature is enabled to allow the git repositories to be cloned on the docker host

## Data System Prerequisites
-   The git database/app project must have automated SQLPlus scripts to deploy/upgrade/rollback the database/app
    -   The given schema(s) on the target database instance must be in the correct state for the desired script to run (e.g. blank database for new deployments, required database version for upgrades/rollbacks, etc.)
    -   If there are different versions of the automated SQLPlus scripts for the different environments (development, test, production) they must incorporate the corresponding environment abbreviation (dev, test, prod) in the script name so the appropriate script can be run for each environment (e.g. deploy_apex_test_v1.5.sql for deploying version 1.5 of the APEX app to the test environment)

## Database Instances
-   For the development docker and database instances the abbreviation used is "dev" 
-   For the test/test docker and database instances the abbreviation used is "test" 
-   For the production docker and database instances the abbreviation used is "prod" 

## CDD Implementation Procedure
-   \*Note: A working example of this Deployment Process for an Oracle/APEX data system is available in the [LHP data system](https://picgitlab.nmfs.local/lhp/lhp-data-management) ([Documentation](https://picgitlab.nmfs.local/lhp/lhp-data-management/-/blob/master/docs/cloud%20docker%20deployment/LHP%20-%20Cloud%20Docker%20Deployment%20Method.md?ref_type=heads)).
-   Add this repository as a git submodule in the given specific data system repository in the appropriate folder (e.g. modules/CDD/)
    -   Copy the [container_database_deployment_template](./container_database_deployment_template) to the root folder of the data system repository and rename it to container_database_deployment
    -   Update the corresponding files in the data system repository based on the following guidance:
        -   [.dockerignore](./container_database_deployment_template/.dockerignore): 
            - Update to include/exclude folders as appropriate to build the docker image, by default the Dockerfile will copy everything from the data system repository root to the /usr/src/oracle_deploy folder within the image
        -   [docker-compose.yml](./container_database_deployment_template/docker-compose.yml):
            -   Update the image and container name appropriately
        -   [deployment_scripts](./container_database_deployment_template/deployment_scripts)
            -   [client_scripts/functions/custom_client_functions.sh](./container_database_deployment_template/deployment_scripts/client_scripts/functions/custom_client_functions.sh):
                -   Update to replace the placeholder content with scripts specifically 

                - 
                - 
                - 
                - 
                - 
                -                 -   Create a separate deployment/upgrade/rollback bash script for each scenario implemented by the data system by copying the 
                    -   







                -   [functions](./docker_template/deployment_scripts/client_scripts/functions)
                    -   [custom_client_functions.sh](./docker_template/deployment_scripts/client_scripts/functions/custom_client_functions.sh):
                        -   (When applicable) transfer_special_files(): Update to transfer any special files that are not managed within the repository  
                            -   \*Note: if there are no special files that need to be transferred then this function body can be blank
                -   (multiple files based on the defined use cases) create a bash script for each use case intended to run on the client machine
                    -   Example: [deploy_versionx.x.sh](./docker_template/deployment_scripts/client_scripts/deploy_versionx.x.sh) for deploying version x.x of the corresponding database to a blank database schema and version x.x of the APEX app
                    -   Ensure that the SCRIPT_TYPE variable value matches the naming convention of the corresponding container script (e.g. [container_deploy_versionx.x.sh](./docker_template/deployment_scripts/container_scripts/container_deploy_versionx.x.sh) for SCRIPT_TYPE="deploy_versionx.x")
                    -   Replace all instances of [DB_NAME] with the corresponding database name and remove "APEX" if the given data system does not include APEX
                    -   \*Note: The main difference between the different use case bash scripts is informing the user which use case is being processed (via echo statements) and setting the $SCRIPT_TYPE variable value (e.g. deploy_version2.0)
            -   [host_scripts](./docker_template/deployment_scripts/host_scripts)
                -   [functions](./docker_template/deployment_scripts/host_scripts/functions):
                    -   [custom_host_functions.sh](./docker_template/deployment_scripts/host_scripts/functions/custom_host_functions.sh):
                        -   prepare_docker_target_dir(): update to copy the directories/files from the corresponding project repository into the folder that will be used to build and run the docker container
            -   [config](./docker_template/deployment_scripts/config)
                -   [docker_host_config.sh](./docker_template/deployment_scripts/config/docker_host_config.sh): update to define each of the bash variables for the docker host configuration
            -   [shared_functions](./docker_template/deployment_scripts/shared_functions)
                -   [custom_shared_functions.sh](./docker_template/deployment_scripts/shared_functions/custom_shared_functions.sh):
                    -   parse_config_data(): update to include all the corresponding bash variables passed in by stdin
                    -   encode_config_data(): update to include all the corresponding bash variables passed in by stdin
                    -   unset_config_variables(): update to unset all bash variables passed in via stdin
            -   [container_scripts](./docker_template/deployment_scripts/container_scripts):
                -   [functions](./docker_template/deployment_scripts/container_scripts/functions):
                    -   [custom_container_functions.sh](./docker_template/deployment_scripts/container_scripts/functions/custom_container_functions.sh):
                        -   generate_connection_strings(): Update to construct the Oracle connection strings for each database schema that will have SQLPlus scripts executed
                        -   unset_connection_strings(): Update to unset the connection string variables defined in generate_connection_strings()
                -   (multiple files based on the defined use cases) create a bash script for each use case intended to run in the container to execute SQLPlus scripts on the specified database instance
                    -   Example: [container_deploy_versionx.x.sh](./docker_template/deployment_scripts/container_scripts/container_deploy_versionx.x.sh) for deploying version x.x of the database to a blank database schema and version x.x of the APEX app
                    -   \*Note: If there are different versions of the automated SQLPlus scripts for the different environments include the ${ENV_NAME} value in the SQLPlus script filename references to ensure the appropriate SQLPlus script is executed
        -   [deployment_script_logs](./docker_template/deployment_script_logs)
            -   \*Note: the log files for the client script executions will be saved in this directory
-   Copy/Add the content from the [.gitignore](./.gitignore) file from this project repository to the root folder of the data system repository the automated deployment method is being implemented in.
    -   \*Note: this file prevents dev, test, and prod oracle credentials as well as instance-specific configuration files from being saved in the data system's repository

## Setup
-   Clone the given git project to a directory on the local client computer
-   Within the project repository create the necessary bash files with the database credentials in each database instance (e.g. secrets.sh in the [dev folder](./docker_template/secrets/dev/) for the development database instance)
	-   \*Note: There is a [secrets template](./docker_template/secrets/secrets.template.sh) file that can be used to create the secrets.sh file for each database instance 
    -   \*Note: the actual configuration files should not be committed to the repository for security purposes, a [.gitignore](./.gitignore) file has been added to the repository to prevent these sensitive files from being included in git.  
-   Within the project repository create the necessary configuration bash files with the database connection information for each database instance
	-   \*Note: There is a [database instance configuration template](./docker_template/deployment_scripts/config/deploy_config.template.sh) file that can be used to create the deploy_config.[ENV].sh file (e.g. deploy_config.dev.sh for the development database instance)
    -   \*Note: the actual configuration files should not be committed to the repository for security purposes, a [.gitignore](./.gitignore) file has been added to the repository to prevent these files from being included in git.  
-   (When applicable) Copy any special files that are not managed in the repository that are called with the transfer_special_files() bash function defined within [custom_client_functions.sh](./docker_template/deployment_scripts/client_scripts/functions/custom_client_functions.sh) to the appropriate locations within the project repository's working folder

## Executing the Appropriate CDD Script
-   \*Note: The [CDD Diagram](./diagrams/container_database_deployment_diagram.drawio.png) provides an overview of the steps associated with the automated client script
-   Execute the specific bash script in the [client_scripts](./docker_template/deployment_scripts/client_scripts) folder for the corresponding use case
    -   For example, the [deploy_versionx.x.sh](./docker_template/deployment_scripts/client_scripts/deploy_versionx.x.sh) will deploy version x.x of the corresponding DB and APEX app to the specific OCI database instance
    -   (shown as step 1 in the diagram) The corresponding client script will prompt the user for the following information:
        -   OCI Environment (dev, test, prod):
            -   This value is saved in $ENV_NAME and provided to subsequent scripts to inform their behavior based on the OCI environment
        -   A log file for each client script execution is saved in [deployment_script_logs](./docker_template/deployment_script_logs) and is named $SCRIPT_TYPE.$(date +%Y%m%d_%H%M%S).log based on the date/time the script is executed.  This file will include the output from the remote host and container scripts
    -   (shown as step 2 in the diagram) The client script will clone the data system repository ($DOCKER_GIT_URL) to the designated folder ($DOCKER_SOURCE_DIR) in docker host via ssh.
    -   (shown as step 3 in the diagram) The client script executes the [initiate_docker.sh](./docker_template/deployment_scripts/host_scripts/initiate_docker.sh) script on the docker host via ssh
        -   When initiate_docker.sh runs on the remote host it changes the permissions on the designated source directory to allow the designated docker account (this is the account allowed to build/run containers) to read the files.
            -   (shown as step 4 in the diagram) The [docker_build_run.sh](./docker_template/deployment_scripts/host_scripts/docker_build_run.sh) script is executed as the designated docker account on the remote host
                -   The script copies the necessary files into the designated directory ($DOCKER_TARGET_DIR) and builds/runs the container
                -   (shown as step 5 in the diagram) The script executes the corresponding bash script within the running container (container_$SCRIPT_TYPE.sh - e.g. [container_deploy_versionx.x.sh](./docker_template/deployment_scripts/container_scripts/container_deploy_versionx.x.sh) will deploy version x.x of the database and APEX app to a blank database).
                    -   (shown as step 6 in the diagram) The bash container script runs a series of SQLPlus scripts that are managed within the corresponding data system repository that perform the processes on the database based on the use case and OCI environment.  
                -   When the container script finishes executing the container is shutdown and the docker files are removed from $DOCKER_TARGET_DIR
            -   The docker source files are removed from $DOCKER_SOURCE_DIR

## Security Features
-   To prevent leakage of sensitive information (e.g. Oracle credentials), this process uses stdin to pass key-value pairs to the bash scripts that require credentials.  
-   This approach prevents the following:
    -   Writing credentials to the file system of the docker host or container
    -   Using environment variables which can be inspected
    -   Passing sensitive information via command-line arguments

## License
See the [LICENSE.md](./LICENSE.md) for details

## Disclaimer
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.

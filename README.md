# PIFSC Container Database Deployment Process

## Overview
When the PIFSC Oracle data center was moved to the cloud it was no longer feasible to deploy/upgrade/rollback databases and APEX applications directly from local workstations via the PIFSC network connection.  In an effort to automate the process and move it closer to the database/application servers the Container Database Deployment (CDD) project was developed.  The CDD can be executed by running a single script on the local client that will execute a series of commands.  This project can be implemented as a submodule in any database system repository to implement the automated deployment process.

## Resources
-   CDD Version Control Information:
    -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments
    -   Version 1.2 (git tag: pifsc_container_database_deployment_v1.2)
    -   Submodules:
        -   Container Deployment Scripts (CDS): 
            -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Deployment-Scripts
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
    -   OpenSSH is configured to specify the username in the ~/.ssh/config file for each docker host (e.g. docker-dev for the dev docker host)
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
-   \*Note: A working example of this Deployment Process for an Oracle/APEX data system is available in the [PIFSC Resource Inventory (PRI)](https://github.com/noaa-pifsc/PIFSC-Resource-Inventory) ([Documentation](https://github.com/noaa-pifsc/PIFSC-Resource-Inventory/blob/master/container_database_deployment/docs/Oracle%20Docker%20Deployment%20Process.md)).
-   Add this repository as a git submodule in the given specific data system repository in the designated folder path within the repository root folder: modules/CDD
    -   Copy the [container_database_deployment_template](./container_database_deployment_template) to the root repository folder of the data system repository and rename it to container_database_deployment
    -   Update the corresponding files in the data system repository based on the following guidance:
        -   [.dockerignore](./container_database_deployment_template/.dockerignore): 
            -   Update to include/exclude folders as appropriate to build the docker image, by default the Dockerfile will copy everything from the data system repository's root folder to the /usr/src/oracle_deploy folder within the image (examples are provided)
        -   [.env](./container_database_deployment_template/.env):
            -   Replace the [PROJECT_CONTAINER_NAME] placeholder to specify a unique container name based on the project, if two containers run with the same name there will be a conflict and they won't be able to run concurrently.
        -   [deployment_scripts](./container_database_deployment_template/deployment_scripts)
            -   [shared_scripts/custom_shared_functions.sh](./container_database_deployment_template/deployment_scripts/shared_scripts/custom_shared_functions.sh):
                -   Update define_env_vars_block()  to validate the required bash variable values and define the list of environment variables that are passed to bash scripts as arguments when they are executed (examples are provided)
            -   [client_scripts/functions/custom_client_functions.sh](./container_database_deployment_template/deployment_scripts/client_scripts/functions/custom_client_functions.sh):
                -   Update client_generate_ssh_env_vars() to validate the required bash variable values and construct the string of ssh environment variables for the database deployment server bash script (examples are provided)
            -   [container_scripts/functions/custom_container_functions.sh](./container_database_deployment_template/deployment_scripts/container_scripts/functions/custom_container_functions.sh):
                -   Update container_generate_connection_strings() to validate the required bash variable values and define the global bash variables that provide the required database connection strings necessary to execute the database deployment scripts (examples are provided)
                    -   \*Note: these connection string variables should reference the bash variables defined in the secrets.sh and deploy_config.${CONTAINER_ENV_NAME}.sh script files.  Do **NOT** hardcode the usernames/passwords or hostname/service name values and save them in the repository
                -   Update container_unset_connection_strings() to unset each of the connection string variables defined in container_generate_connection_strings() to ensure the credentials are not left available in the given bash/ssh session
            -   [container_scripts](./container_database_deployment_template/deployment_scripts/container_scripts):
                -   Create a new .sh file for each database deployment/upgrade/rollback script implemented in the data system project in the format container_${CONTAINER_SCRIPT_TYPE}.sh where ${CONTAINER_SCRIPT_TYPE} is provided by the user at runtime when the [client_scripts/client_deploy_database.sh](./container_database_deployment_template/deployment_scripts/client_scripts/client_deploy_database.sh) script is executed
                    -   [container_deploy_version2.0.template.sh](./container_database_deployment_template/deployment_scripts/container_scripts/container_deploy_version2.0.template.sh) is provided as an example of a container database deployment script with a ${CONTAINER_SCRIPT_TYPE} value of "deploy_version2.0" so it can be copied and renamed based on the ${CONTAINER_SCRIPT_TYPE} value and to remove the ".template"
            -   [config/custom_container_config.sh](./container_database_deployment_template/deployment_scripts/config/custom_container_config.sh):
                -   Update the global bash variable declarations based on the specific data system being implemented, each one has comments and an example.  In some cases the variable declaration has a placeholder enclosed by brackets that are intended to be replaced with appropriate values for the given data system:
                    -   SECRET_MAPPING_ARR is a special variable that is used to send the database credentials between bash scripts, each array element value needs to correspond with a global bash variable declaration in the corresponding secrets.sh file
        -   [Container Database Deployment Process.template.md](./container_database_deployment_template/docs/Container%20Database%20Deployment%20Process.template.md):
            -   Rename the file to an appropriate name for the given data system (without the ".template") 
                -   Update the [DATA SYSTEM NAME] placeholder with the given data system name

## Adding New Use Cases
-   Create a new bash script in the [container_scripts](../../container_database_deployment/deployment_scripts/container_scripts) folder with the name container_${CONTAINER_SCRIPT_TYPE}.sh where ${CONTAINER_SCRIPT_TYPE} is the value provided at runtime when the [client_deploy_database.sh](./container_database_deployment_template/deployment_scripts/client_scripts/client_deploy_database.sh) bash script is executed
    -   \*Note: an existing container bash script (e.g. [container_deploy_version2.0.template.sh](./container_database_deployment_template/deployment_scripts/container_scripts/container_deploy_version2.0.template.sh)) can be copied and modified to create a bash script for the new use case.  
    -   Update the sqlplus commands to run the automated SQLPlus scripts to deploy/upgrade/rollback the database schema(s) and APEX app
        -   If there are different versions of the automated SQLPlus scripts for the different environments include the ${CONTAINER_ENV_NAME} value in the SQLPlus script filename references to ensure the appropriate SQLPlus script is executed

## Setup
-   Clone the given git project to a directory on the local client computer
-   Within the project repository create the necessary bash files with the database credentials in each database instance (e.g. secrets.sh in the [dev folder](./container_database_deployment_template/secrets/dev/) for the development database instance)
	-   \*Note: There is a [secrets template](./container_database_deployment_template/secrets/secrets.template.sh) file that can be used to create the secrets.sh file for each database instance 
    -   \*Note: the actual secret files should not be committed to the repository for security purposes, a [.gitignore](./container_database_deployment_template/.gitignore) file has been added to the repository to prevent these sensitive files from being included in git.  
-   Within the project repository create the necessary configuration bash files with the database connection information for each database instance
	-   \*Note: There is a [database instance configuration template](./container_database_deployment_template/deployment_scripts/config/deploy_config.template.sh) file that can be used to create the deploy_config.[ENV].sh file (e.g. deploy_config.dev.sh for the development database instance)
    -   \*Note: the actual configuration files should not be committed to the repository for security purposes, a [.gitignore](./container_database_deployment_template/.gitignore) file has been added to the repository to prevent these files from being included in git.  

## Executing the Appropriate CDD Script
-   \*Note: The [CDD Diagram](./diagrams/container_database_deployment_diagram.drawio.png) provides an overview of the steps associated with the automated client script
-   (shown as step 1 in the diagram) Execute the [client_deploy_database.sh](./container_database_deployment_template/deployment_scripts/client_scripts/client_deploy_database.sh) bash script and optionally specify the appropriate arguments.
    -   For example, to deploy the development version to a container server for the deploy_version2.0 script type use the following command:
        -   `bash client_deploy_database.sh dev server deploy_version2.0`
    -   If some/all of the arguments are not provided when the script is executed the script will prompt the user for the values of the arguments that were not provided:
        -   `bash client_deploy_database.sh`
        -   Database Environment (dev, test, prod):
            -   This value is saved in $CONTAINER_ENV_NAME and provided to subsequent scripts to inform their behavior based on the database environment
        -   Deployment Destination (local, server)
            -   This value is saved in $CONTAINER_DEPLOY_DEST and provided to subsequent scripts to specify whether the container is deployed locally for development purposes or on a container server
        -   Script Type (e.g. deploy_version1.5 to deploy version 1.5 of the database to a blank schema by calling the container_deploy_version1.5.sh container deployment script)
            -   This value is saved in $CONTAINER_SCRIPT_TYPE and provided to subsequent scripts to specify which automated container database deployment script is executed
    -   A log file for each client script execution is saved in [deployment_script_logs](./container_database_deployment_template/deployment_script_logs) and is named client_deploy_database.sh.$(date +%Y%m%d_%H%M%S).log based on the date/time the script is executed.  This file will include the output from the remote host and container scripts
    -   (shown as step 2 in the diagram) The client script will clone the data system repository ($CONTAINER_GIT_URL) to the designated folder ($CONTAINER_HOST_PROJECT_PATH) in docker host via ssh.
    -   (shown as step 3 in the diagram) The client script executes the [host_deploy_database.sh](./container_database_deployment_template/deployment_scripts/host_scripts/host_deploy_database.sh) script on the docker host via ssh
        -   When initiate_container.sh runs on the remote host it changes the permissions on the designated source directory to allow the designated docker account (this is the account allowed to build/run containers) to read the files.
            -   (shown as step 4 in the diagram) The [host_deploy_database_elev_privs.sh](./container_database_deployment_template/deployment_scripts/host_scripts/host_deploy_database_elev_privs.sh) script is executed as the designated docker account ($CONTAINER_ACCOUNT_NAME) on the remote host
                -   The script builds/runs the container
                -   (shown as step 5 in the diagram) The script executes the corresponding bash script within the running container (container_$CONTAINER_SCRIPT_TYPE.sh - e.g. ./container_database_deployment_template/deployment_scripts/container_scripts/container_deploy_versionx.x.sh] will deploy version x.x of the database and APEX app to a blank database).
                    -   (shown as step 6 in the diagram) The bash container script runs a series of SQLPlus scripts that are managed within the corresponding data system repository that perform the processes on the database based on the use case and database environment.  
            -   The docker source files are removed from $CONTAINER_HOST_PROJECT_PATH

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
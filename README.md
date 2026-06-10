# PIFSC Container Database Deployment Module

## Overview
The Container Database Deployment (CDD) module was developed to automate the execution of SQL commands on a specified database instance from within a container. When the container is within the same network the performance improvement can be substantial when compared to running the same SQL commands from the PIFSC network. The CDD can be executed by running a single script on a client computer that will build and run the container and then connect to the container to execute a series of database commands. The CDD module builds upon the [Container Deployment System (CDS)](https://github.com/noaa-pifsc/PIFSC-Container-Deployment-Scripts) module to provide database-specific deployment workflows. This project can be implemented as a git submodule in any database system repository to implement the automated deployment process.

## Resources
-   CDD Version Control Information:
    -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments
    -   Version: 1.4 (git tag: pifsc_container_database_deployment_v1.4)
-   [Container Database Deployment Diagram](./diagrams/container_database_deployment_diagram.drawio.png)
    -   [Container Database Deployment Diagram Source File](./diagrams/container_database_deployment_diagram.drawio)

## Requirements
-   Client machine:
    -   Bash (Linux) or Git Bash (Windows)
    -   git
    -   For remote container deployments only:
        -   SSH is setup to work with CAC authentication
        -   SSH is configured to specify the username in the ~/.ssh/config file for each container host (e.g. docker_dev for the dev container host)
            -   The ForwardAgent feature is enabled to allow the git repositories to be cloned on the container host
-   Container host: 
    -   Connectivity to the corresponding database instance
    -   Docker
    -   dos2unix
    -   git
-   Data System Prerequisites:
    -   Automated database deployment scripts that can be executed via SQL*Plus to deploy/upgrade/rollback the database/app are required by the database/app project 
    -   The given schema(s) on the target database instance must be in the correct state for the desired script to run (e.g. blank database for new deployments, required database version for upgrades/rollbacks, etc.)
    -   If there are different versions of the automated scripts for the different environments (development, test, production) they must incorporate the corresponding environment abbreviation (dev, test, prod) in the script name so the appropriate script can be run for each environment (e.g. deploy_apex_test_v1.5.sql for deploying version 1.5 of the APEX app to the test environment)

## Database Instances
-   For the development container and database instances the abbreviation used is "dev" 
-   For the test/test container and database instances the abbreviation used is "test" 
-   For the production container and database instances the abbreviation used is "prod" 

## Dependencies
\* Note: all dependencies are implemented as git submodules in the [modules](./modules) folder
-   ### Container Deployment System (CDS) Module Version Control Information
    -   folder path: [modules/CDS](./modules/CDS)
    -   Version Control Information:
        -   URL: <git@github.com:noaa-pifsc/PIFSC-Container-Deployment-System.git>
        -   Version: 1.3 (Git tag: pifsc_container_deployment_system_v1.3)

## Naming Conventions
-   ### Functions
    -   The function naming convention follows the [namespace]\_[scope]\_[action] format, allowing developers to instantly identify the module a function belongs to and the execution environment where it is designed to run.
    -   Namespace: cdd_
    -   Execution Scopes: 
        -   client_: Executes on the developer workstation.
        -   container_: Executes inside the container.
        -   host_: Executes on the remote container host server.
        -   shared_: Utilities utilized across multiple execution scopes.
    -   Resources: 
        -   [CDS function naming conventions](./modules/CDS/README.md#functions)
-   ### Variables
    -   The CDD follows the defined [CDS variable naming conventions](./modules/CDS/README.md#variables)

## CDD Folder Structure
-   ### Project-Specific CDD Folder Structure
    -   The [container_database_deployment_template](./container_database_deployment_template) folder is provided to streamline the process of implementing the CDD for a given container by copying to the root folder of the given project's repository:
        -   The [deployment_script_logs](./container_database_deployment_template/deployment_script_logs) folder contains logs from the execution of scripts to prepare and deploy the container
        -   The [deployment_scripts](./container_database_deployment_template/deployment_scripts) folder contains scripts to prepare and deploy the container project
            -   The [client_scripts](./container_database_deployment_template/deployment_scripts/client_scripts) folder contains scripts to execute on the client computer
            -   The [config](./container_database_deployment_template/deployment_scripts/config) folder contains configuration files to define the CDD configuration
            -   The [container_scripts](./container_database_deployment_template/deployment_scripts/container_scripts) folder contains scripts to that are executed from within the container
            -   The [host_scripts](./container_database_deployment_template/deployment_scripts/host_scripts) folder contains scripts to execute on the container host
            -   The [shared_scripts](./container_database_deployment_template/deployment_scripts/shared_scripts) folder contains scripts that are executed in multiple execution scopes
        -   The [docs](./container_database_deployment_template/docs) folder contains documentation for the project-specific CAD implementation
        -   The [secrets](./container_database_deployment_template/secrets) folder contains subfolders for each one of the [Database Instances](#database-instances) and a secrets.sh file for each subfolder (e.g. dev/secrets.sh for the development instance) that contains the definition for all secret variables required for the database deployment (these files are not committed to version control)
        -   The [.dockerignore](./container_database_deployment_template/.dockerignore) file defines which source folders/files will be copied into the container image
        -   The [.env](./container_database_deployment_template/.env) file defines a project-specific container name to prevent naming conflicts to allow multiple CDD containers to run concurrently on the same docker host.
        -   The [.gitignore](./container_database_deployment_template/.gitignore) file prevents sensitive files from being committed
        -   The [docker-compose.yml](./container_database_deployment_template/docker-compose.yml) file defines the CDD container configuration
        -   The [Dockerfile](./container_database_deployment_template/Dockerfile) file defines the build process for the CDD container
-   ### CDD Documentation and Source Code Folder Structure
    -   The [diagrams](./diagrams) folder contains the CDD execution diagram
    -   The [modules](./modules) folder contains a pointer to git submodules implemented for the CDD
        -   The [CDS](./modules/CDS) folder contains a pointer the CDS repository implemented as a git submodule
    -   The [src](./src) folder contains .sh files that define the reusable CDD module bash functions
    -   The [README.md](./README.md) file documents the CDD module
-   #### Repository Folder Diagram:
    ```
    .
    |--- container_database_deployment_template
    |    |--- deployment_script_logs
    |    |--- deployment_scripts
    |    |    |--- client_scripts
    |    |    |--- config
    |    |    |--- container_scripts
    |    |    |--- host_scripts
    |    |    |--- shared_scripts
    |    |--- docs
    |    |--- secrets 
    |    |---  .dockerignore
    |    |---  .env
    |    |---  .gitignore
    |    |---  docker-compose.yml
    |    |---  Dockerfile
    |--- diagrams
    |--- modules
    |    |--- CDS
    |--- src
    |--- README.md
    ```

## CDD Implementation Procedure
-   \*Note: Working examples of the CDD are listed below:
    -   Database deployment only: [PIFSC Resource Inventory (PRI) Database](https://github.com/noaa-pifsc/PIFSC-Resource-Inventory) ([Documentation](https://github.com/noaa-pifsc/PIFSC-Resource-Inventory/blob/master/container_database_deployment/docs/PRI%20-%20Container%20Database%20Deployment%20Process.md)).
    -   Database and Apex deployment: [Life History Program (LHP) Data System](https://github.com/noaa-pifsc/LHP-Data-Management) ([Documentation](https://github.com/noaa-pifsc/LHP-Data-Management/blob/master/container_database_deployment/docs/LHP%20-%20Container%20Database%20Deployment%20Process.md))
    -   Data Freeze and Verification: [Longline Cost Earnings (LCE) Data System](https://picgitlab.nmfs.local/esd-sees/longline-cost-earnings) ([Documentation](https://picgitlab.nmfs.local/esd-sees/longline-cost-earnings/-/blob/master/container_database_deployment/docs/Container%20Database%20Deployment%20Process.md?ref_type=heads))
-   Add this repository as a git submodule in the given specific data system repository in the designated folder path within the repository root folder: modules/CDD
    -   Copy the [container_database_deployment_template](./container_database_deployment_template) to the root repository folder of the data system repository and rename it to container_database_deployment
    -   Update the corresponding files in the data system repository based on the following guidance:
        -   [.dockerignore](./container_database_deployment_template/.dockerignore): 
            -   Update to include/exclude folders as appropriate to build the container image, by default the Dockerfile will copy everything from the data system repository's root folder to the /usr/src/database_deploy folder within the image (examples are provided)
        -   [.env](./container_database_deployment_template/.env):
            -   Replace the [CONTAINER_NAME] placeholder to specify a unique container name based on the project, if two containers run with the same name there will be a conflict and they won't be able to run concurrently.
        -   [deployment_scripts](./container_database_deployment_template/deployment_scripts)
            -   [container_scripts/functions/custom_container_functions.sh](./container_database_deployment_template/deployment_scripts/container_scripts/functions/custom_container_functions.sh):
                -   Update proj_container_custom_generate_connection_strings() to validate the required bash variable values and define the global bash variables that provide the required database connection strings necessary to execute the database deployment scripts (examples are provided)
                    -   \*Note: these connection string variables should reference the bash variables defined in the secrets.sh and deploy_config.$\{env_name\}.sh script files.  Do **NOT** hardcode the usernames/passwords or hostname/service name values and save them in the repository
            -   [container_scripts](./container_database_deployment_template/deployment_scripts/container_scripts):
                -   Create a new .sh file for each database deployment/upgrade/rollback script implemented in the data system project in the format container_$\{container_script_type\}.sh where $\{container_script_type\} is provided by the user at runtime when the [client_scripts/client_deploy_database.sh](./container_database_deployment_template/deployment_scripts/client_scripts/client_deploy_database.sh) script is executed
                    -   [container_deploy_version2.0.template.sh](./container_database_deployment_template/deployment_scripts/container_scripts/container_deploy_version2.0.template.sh) is provided as an example of a container database deployment script with a $\{container_script_type\} value of "deploy_version2.0" so it can be copied and renamed based on the $\{container_script_type\} value and to remove the ".template"
                    -   Update the sqlplus commands to run the automated SQLPlus scripts to deploy/upgrade/rollback the database schema(s), and optionally APEX app(s)
            -   [config/custom_container_config.sh](./container_database_deployment_template/deployment_scripts/config/custom_container_config.sh):
                -   Update the global bash variable declarations based on the specific data system being implemented, each one has comments and an example.  In some cases the variable declaration has a placeholder enclosed by brackets that are intended to be replaced with appropriate values for the given data system:
                    -   SECRET_MAPPING_ARR is a special variable that is used to send the database credentials between bash scripts, each array element value needs to correspond with a global bash variable declaration in the corresponding secrets.sh file
        -   [Container Database Deployment Process.template.md](./container_database_deployment_template/docs/Container%20Database%20Deployment%20Process.template.md):
            -   Rename the file to an appropriate name for the given data system (without the ".template") 
                -   Update the [DATA SYSTEM NAME] placeholder with the given data system name

## Setup
-   Recursively clone the given git project to a directory on the local client computer
-   Within the project repository create the necessary bash files with the database credentials in each database instance (e.g. secrets.sh in the [dev folder](./container_database_deployment_template/secrets/dev/) for the development database instance)
	-   \*Note: There is a [secrets template](./container_database_deployment_template/secrets/secrets.template.sh) file that can be used to create the secrets.sh file for each database instance 
    -   \*Note: the actual secret files should not be committed to the repository for security purposes, a [.gitignore](./container_database_deployment_template/.gitignore) file has been added to the repository to prevent these sensitive files from being included in git.  
-   Within the project repository create the necessary configuration bash files with the database connection information for each database instance
	-   \*Note: There is a [database instance configuration template](./container_database_deployment_template/deployment_scripts/config/deploy_config.template.sh) file that can be used to create the deploy_config.[ENV].sh file (e.g. deploy_config.dev.sh for the development database instance)
    -   \*Note: the actual configuration files should not be committed to the repository for security purposes, a [.gitignore](./container_database_deployment_template/.gitignore) file has been added to the repository to prevent these files from being included in git.  

## Executing the CDD Script
-   \*Note: The [CDD Diagram](./diagrams/container_database_deployment_diagram.drawio.png) provides an overview of the steps associated with the automated client script
-   (shown as step 1 in the diagram) Execute the [client_deploy_database.sh](./container_database_deployment_template/deployment_scripts/client_scripts/client_deploy_database.sh) bash script and optionally specify the appropriate arguments.
    -   For example, to deploy the development version to a container server for the deploy_version2.0 script type use the following command:
        -   `bash client_deploy_database.sh dev server deploy_version2.0`
    -   If some/all of the arguments are not provided when the script is executed the script will prompt the user for the values of the arguments that were not provided:
        -   `bash client_deploy_database.sh`
        -   Database Environment (dev, test, prod):
            -   This value is saved in $env_name and provided to subsequent scripts to inform their behavior based on the database environment
        -   Deployment Destination (local, server)
            -   This value is saved in $deploy_dest and provided to subsequent scripts to specify whether the container is deployed locally for development purposes or on a container server
        -   Script Type (e.g. deploy_version1.5 to deploy version 1.5 of the database to a blank schema by calling the container_deploy_version1.5.sh container deployment script)
            -   This value is saved in $container_script_type and provided to subsequent scripts to specify which automated container database deployment script is executed
    -   A log file for each client script execution is saved in [deployment_script_logs](./container_database_deployment_template/deployment_script_logs) and is named client_deploy_database.sh.$(date +%Y%m%d_%H%M%S).log based on the date/time the script is executed.  This file will include the output from the remote host and container scripts
    -   (shown as step 2 in the diagram) The client script will clone the data system repository ($GIT_URL) to the designated folder ($HOST_SOURCE_PATH) in container host via ssh.
    -   (shown as step 3 in the diagram) The client script executes the [host_deploy_database.sh](./container_database_deployment_template/deployment_scripts/host_scripts/host_deploy_database.sh) script on the container host via ssh to initiate the container deployment process
        -   When host_deploy_database.sh runs on the remote host it changes the permissions on the designated source directory to allow the designated container account (this is the account allowed to build/run containers) to read the files.
            -   (shown as step 4 in the diagram) The [host_deploy_database_elev_privs.sh](./container_database_deployment_template/deployment_scripts/host_scripts/host_deploy_database_elev_privs.sh) script is executed as the designated container account ($PRIV_USER) on the remote host
                -   The script builds/runs the container
                -   (shown as step 5 in the diagram) The script executes the corresponding bash script within the running container: container_$\{container_script_type\}.sh (e.g. container_deploy_versionx.x.sh will deploy version x.x of the database and APEX app to a blank database).
                    -   (shown as step 6 in the diagram) The bash container script runs a series of SQLPlus scripts that are managed within the corresponding data system repository that perform the processes on the database based on the use case and database environment.  
            -   The container source files are removed from $HOST_SOURCE_PATH

## Security Features
-   The CDD inherits security features from the [CDS module](./modules/CDS/README.md#security-features).
-   Guaranteed Container Teardown (EXIT Traps): The deployment lifecycle is wrapped in a heavily enforced trap ... EXIT mechanism. At runtime the framework extracts and hardcodes the necessary cleanup variables immediately upon execution. If a deployment script encounters a fatal error, crashes, or is manually aborted, the trap guarantees that the container and all sensitive temporary data are immediately destroyed, preventing containers from lingering.
-   Decoupled Configuration Adapter Pattern: The core CDD engine enforces a strict Separation of Concerns. It remains completely independent of project-specific global variables. It only operates on strictly validated associative arrays and arguments, ensuring that the engine itself cannot inadvertently expose or mishandle project-specific configurations.

## Design Strategy
-   Leverage the [CDS module](./modules/CDS/README.md#design-strategy) for its collection of flexible and reusable container functions
    -   Benefits:
        -   Reduce the amount of custom code needed for the CDD
-   Define a collection of flexible and reusable container functions for a variety of workflows that support running database scripts from a container
    -   Benefits:
        -   Promote code reuse
        -   Reduce the amount of custom code needed for specific database projects to implement the CDD

## License
See the [LICENSE.md](./LICENSE.md) for details

## Disclaimer
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an 'as is' basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.
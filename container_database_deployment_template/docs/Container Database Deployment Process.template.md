# Container Database Deployment Process Documentation

## Overview
When the PIFSC Oracle data center was moved to the cloud it was no longer feasible to deploy/upgrade/rollback databases and APEX applications directly from local workstations via the PIFSC network connection.  In an effort to automate the process and move it closer to the database/application servers the [Container Database Deployment (CDD)](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/) was developed.  The CDD can be executed by running a single script on the local client that will execute a series of commands.  The [DATA SYSTEM NAME] data system implements the CDD for several use cases.

## Resources
-   CDD Version Control Information:
    -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments

## Platform Requirements
-   See [CDD Platform Requirements](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#platform-requirements)

## Data System Prerequisites
-    See [CDD Data System Prerequisites](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#data-system-prerequisites)

## Database Instances
-    See [CDD Database Instances](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#database-instances)

## Naming Conventions
-   ### Functions:
    -   The function naming convention follows the [namespace]_[scope]_[action] format, allowing developers to instantly identify the module a function belongs to and the execution environment where it is designed to run.
    -   Namespace: proj_
    -   Execution Scopes: 
        -   client_: Executes on the developer workstation, CI/CD runner, or jumpbox before handing off to the CDD framework.
        -   container_: Executes inside the container to dynamically map localized secrets to connection strings.
        -   shared_: Utilities utilized across multiple execution scopes.
    -   See [CDD Function Naming Conventions](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#functions)
-   ### Variables
    -   This project follows the defined [CDD variable naming conventions](./modules/CDD/README.md#variables)

## Security Features
-   See [CDD Security Features](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#security-features)

## Setup
-    See [CDD Setup](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#setup)

## Executing the Appropriate Automated Client Script
-   The [CDD Documentation](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#executing-the-appropriate-cdd-script) contains detailed information about the automated deployment process

## Adding New Use Cases
-    See [CDD Adding New Use Cases](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#adding-new-use-cases)

## Security Features
-   See [CDD Security Features](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#security-features)
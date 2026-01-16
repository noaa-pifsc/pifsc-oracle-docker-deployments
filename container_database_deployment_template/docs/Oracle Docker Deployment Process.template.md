# Oracle Docker Deployment Process Documentation

## Overview
When the PIFSC Oracle data center was moved to the cloud it was no longer feasible to deploy/upgrade/rollback databases and APEX applications directly from local workstations via the PIFSC network connection.  In an effort to automate the process and move it closer to the database/application servers the [Container Database Deployment (CDD)](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/) was developed.  The CDD can be executed by running a single script on the local client that will execute a series of commands.  The [DATA SYSTEM NAME] data system implements the CDD for several use cases.

## Resources
-   CDD Version Control Information:
    -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments
    -   Version 1.2 (git tag: pifsc_container_database_deployment_v1.2)

## Platform Requirements
-   See [CDD Platform Requirements](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#platform-requirements)

## Data System Prerequisites
-    See [CDD Data System Prerequisites](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#data-system-prerequisites)

## Database Instances
-    See [CDD Database Instances](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#database-instances)

## Setup
-    See [CDD Setup](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#setup)

## Executing the Appropriate Automated Client Script
-   The [CDD Documentation](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#executing-the-appropriate-cdd-script) contains detailed information about the automated deployment process

## Adding New Use Cases
-    See [CDD Adding New Use Cases](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#adding-new-use-cases)

## Security Features
-   See [CDD Security Features](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/blob/main/README.md#security-features)
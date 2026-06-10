# [DATA SYSTEM NAME] - Container Database Deployment Process Documentation

## Overview
The [Container Database Deployment (CDD)](https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments/) was developed to automate the execution of SQL commands on a specified database instance from within a container. When the container is within the same network the performance improvement can be substantial when compared to running the same SQL commands from the PIFSC network. The CDD can be executed by running a single script on the local client that will execute a series of commands. The [DATA SYSTEM NAME] data system implements the CDD for several use cases.

## Resources
-   Refer to the [CDD Resources](../../modules/CDD/README.md#resources) documentation

## Requirements
-   Refer to the [CDD Requirements](../../modules/CDD/README.md#requirements) documentation

## Database Instances
-   Refer to the [CDD Database Instances](../../modules/CDD/README.md#database-instances) documentation

## Dependencies
-   Refer to the [CDD Dependencies](../../modules/CDD/README.md#dependencies) documentation
-   CDD Version Control Information:
    -   URL: https://github.com/noaa-pifsc/PIFSC-Container-Database-Deployments

## Naming Conventions
-   ### Functions:
    -   The function naming convention follows the [namespace]\_[scope]\_[action] format, allowing developers to instantly identify the module a function belongs to and the execution environment where it is designed to run.
    -   Namespace: proj_
    -   Execution Scopes: 
        -   client_: Executes on the developer workstation.
        -   container_: Executes inside the container.
        -   host_: Executes on the remote container host server.
        -   shared_: Utilities utilized across multiple execution scopes.
    -   Refer to the [CDD Function Naming Conventions](../../modules/CDD/README.md#functions) documentation
-   ### Variables
    -   This project follows the defined [CDD variable naming conventions](../../modules/CDD/README.md#variables)

## CDD Folder Structure
-   Refer to the [CDD Folder Structure](../../modules/CDD/README.md#cdd-folder-structure) documentation

## CDD Implementation Procedure
-   Refer to the [CDD Implementation Procedure](../../modules/CDD/README.md#cdd-implementation-procedure) documentation

## Setup
-    Refer to the [CDD Setup](../../modules/CDD/README.md#setup) documentation

## Executing the CDD Script
-   Refer to the [CDD Executing the CDD Script](../../modules/CDD/README.md#executing-the-cdd-script) documentation

## Security Features
-   Refer to the [CDD Security Features](../../modules/CDD/README.md#security-features) documentation

## Design Strategy
-   Refer to the [CDD Design Strategy](../../modules/CDD/README.md#design-strategy) documentation
    -   Benefits:
        -   Reduce the amount of custom code needed to run the database scripts from a container
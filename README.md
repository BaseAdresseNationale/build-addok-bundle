## BUILD-ADDOK-BUNDLE

[Read the french version LISEZ-MOI.md](LISEZ-MOI.md)

## Description

This service is used to generate the France addok bundle. It downloads the input data from a S3 bucket, generates the bundle and upload it to S3 at the same path/directory.

## Installation

Prerequisites : 
- Docker
- Docker-compose

Instructions on how to deploy the service (dev mode) :
1. Clone this repository
2. Copy the .env.sample and enter the env variables values
2. Start the docker containers : 

```bash
docker-compose up --build -d
```

This will deploy 3 containers : 
- the build-addok-bundle container: main container where all the process happens.
- the minio container : used to simulate a S3 service locally. To open the interface, go to http://localhost:9001 (if you have changed the env variable MINIO_FRONT_PORT, change the url accordingly : http://localhost:${MINIO_FRONT_PORT})
- the minio-init container : used to prepare the minio with data. It creates a bucket with the name: ${S3_BUCKET} env variable and upload an input data file at the path ${S3_ADDOK_PATH}. This file will then be used by the build-addok-bundle container as the main input file to create the bundle.

The start of those container is made in a specific order automatically : 
- First the minio container starts
- When the minio service is up and running, the minio-init starts, does its process and stops.
- Finally, when the minio-init stops, the build-addok-bundle container starts, does its process and stops.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
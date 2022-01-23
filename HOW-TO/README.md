# README

## Prerequisites
- required images must be built/exist
- deploy Postgresql (local to the server or otherwise)

## To deploy 
- run `generate_configs.sh` to create "actual" configs which will be mounted over the defaults in the Docker image
- `docker-compose up -d`

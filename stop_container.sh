#!/bin/bash
set -e

# Define variables
CONTAINER_NAME="simple-python-app"  # Name of the Docker container

echo "Checking if the container is running..."
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping the running container..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    echo "Container stopped and removed successfully."
else
    echo "No running container found with the name $CONTAINER_NAME."
fi

#!/bin/bash

CONTAINER_NAME="simple-python-app"

echo "Stopping the container if it exists..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Container stopped."

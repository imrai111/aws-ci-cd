#!/bin/bash

CONTAINER_NAME="simple-python-app"
PORT=80

echo "Starting the container..."
docker run -d --name $CONTAINER_NAME -p $PORT:80 simple-python-app:latest

if [ $? -eq 0 ]; then
  echo "Container started successfully."
else
  echo "Failed to start the container."
  exit 1
fi

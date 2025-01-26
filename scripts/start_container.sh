#!/bin/bash

# Fetch AWS credentials from Parameter Store
AWS_ACCESS_KEY_ID=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-access-key-id" --with-decryption --query "Parameter.Value" --output text)
AWS_SECRET_ACCESS_KEY=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-secret-access-key" --with-decryption --query "Parameter.Value" --output text)

# Set the AWS credentials as environment variables (for the current session)
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Fetch the ECR URI from Parameter Store
ECR_URI=$(aws ssm get-parameter --name "/myaap/docker-registry/url" --with-decryption --query "Parameter.Value" --output text)

# Check if port 5000 is in use
if lsof -i :5000; then
  echo "Port 5000 is already in use, finding and stopping the process..."
  # Identify the process using port 5000 and kill it
  PID=$(sudo lsof -t -i :5000)
  sudo kill -9 $PID
else
  echo "Port 5000 is free, proceeding with next steps..."
fi

# Check if the image already exists locally
if [[ "$(docker images -q $ECR_URI:latest 2> /dev/null)" != "" ]]; then
  echo "Image already exists locally. Moving the existing image to a temporary directory..."
  
  # Create a temporary directory to store the existing image
  mkdir -p /tmp/docker_images
  docker save $ECR_URI:latest -o /tmp/docker_images/simple-python-flask-app.tar

  # Stop and remove the old container if it's using port 5000
  CONTAINER_NAME="simple-python-flask-app"
  EXISTING_CONTAINER=$(docker ps -a -q -f "name=$CONTAINER_NAME")
  if [ "$EXISTING_CONTAINER" ]; then
    echo "Stopping and removing the existing container..."
    docker stop $EXISTING_CONTAINER
    docker rm $EXISTING_CONTAINER
  fi
else
  echo "No existing image found, proceeding with new image..."
fi

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URI

# Pull the Docker image
echo "Pulling the latest Docker image from ECR..."
docker pull $ECR_URI:latest

# Run the container with the latest image
echo "Running the container with the latest image..."
docker run -d --name simple-python-flask-app -p 5000:5000 $ECR_URI:latest

# Success message
echo "Container started and exposed on port 5000."


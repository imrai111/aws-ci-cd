#!/bin/bash
set -e

#!/bin/bash
set -e

# Define variables
AWS_REGION="us-east-1"
S3_BUCKET="simple-python-bucket"
ARTIFACT_PATH="artifacts/docker-image.tar.gz"
DOCKER_IMAGE_TAR="docker-image.tar.gz"
CONTAINER_NAME="simple-python-app"
PORT=5000  # Flask app listening port

# Export AWS region
export AWS_REGION

# Fetch AWS credentials from Parameter Store
echo "Fetching AWS credentials from Parameter Store..."
AWS_ACCESS_KEY_ID=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-access-key-id" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)
AWS_SECRET_ACCESS_KEY=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-secret-access-key" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)

# Configure AWS credentials for S3 access
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Step 1: Download the Docker image tar.gz from S3
echo "Downloading Docker image tar.gz from S3..."
aws s3 cp s3://$S3_BUCKET/$ARTIFACT_PATH $DOCKER_IMAGE_TAR

# Step 2: Extract the tar.gz file (if necessary)
echo "Extracting Docker image tar.gz file..."
tar -xzf $DOCKER_IMAGE_TAR

# Step 3: Load the Docker image
echo "Loading Docker image into Docker..."
docker load -i ${DOCKER_IMAGE_TAR%.gz}  # Remove .gz extension for the Docker tar file

# Step 4: Start the Docker container
echo "Starting the Docker container with the loaded image..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:5000 \
  simple-python-app:latest

echo "Container started successfully!"


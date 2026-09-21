#!/bin/bash
# Script to build Docker images and push to ECR

# Variables
AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
APP_NAME="streamingapp"
IMAGE_TAG="latest"

# Authenticate Docker to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION \
| docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push each service
declare -A PATHS=(
  ["frontend"]="frontend"
  ["auth"]="backend/authService"
  ["streaming"]="backend/streamingService"
  ["admin"]="backend/adminService"
  ["chat"]="backend/chatService"
)

for service in "${!PATHS[@]}"; do
  echo "Building image for $service..."
  docker build -t $APP_NAME/$service:${IMAGE_TAG} ${PATHS[$service]}

  echo "Tagging image..."
  docker tag $APP_NAME/$service:${IMAGE_TAG} \
    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME/$service:${IMAGE_TAG}

  echo "Pushing image to ECR..."
  docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$APP_NAME/$service:${IMAGE_TAG}
done

echo "✅ All images built and pushed successfully."

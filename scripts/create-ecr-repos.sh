#!/bin/bash
# Script to create ECR repositories for StreamingApp microservices

# Variables
AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
APP_NAME="streamingapp"

# List of services
SERVICES=("frontend" "auth" "streaming" "admin" "chat")

# Create repositories
for service in "${SERVICES[@]}"; do
  echo "Creating ECR repository: $APP_NAME/$service"
  aws ecr create-repository \
    --repository-name "$APP_NAME/$service" \
    --region "$AWS_REGION" || echo "Repository $APP_NAME/$service already exists"
done

echo "✅ All repositories created (or already exist)."

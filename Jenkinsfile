```text
pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '243747081594'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPOSITORY = "${ECR_REGISTRY}/streaming-frontend"
        BACKEND_REPOSITORY  = "${ECR_REGISTRY}/streaming-backend"

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    set -e

                    echo "Checking required tools..."

                    git --version
                    docker --version
                    aws --version

                    echo "AWS identity:"
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Build Frontend Image') {
            steps {
                echo 'Building frontend Docker image...'

                sh '''
                    set -e

                    docker build \
                        -t ${FRONTEND_REPOSITORY}:${IMAGE_TAG} \
                        -t ${FRONTEND_REPOSITORY}:latest \
                        ./frontend
                '''
            }
        }

        stage('Build Backend Image') {
            steps {
                echo 'Building backend Docker image...'

                sh '''
                    set -e

                    docker build \
                        -t ${BACKEND_REPOSITORY}:${IMAGE_TAG} \
                        -t ${BACKEND_REPOSITORY}:latest \
                        ./backend
                '''
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                echo 'Logging in to Amazon ECR...'

                sh '''
                    set -e

                    aws ecr get-login-password \
                        --region ${AWS_REGION} \
                    | docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Frontend Image') {
            steps {
                echo 'Pushing frontend image to ECR...'

                sh '''
                    set -e

                    docker push ${FRONTEND_REPOSITORY}:${IMAGE_TAG}
                    docker push ${FRONTEND_REPOSITORY}:latest
                '''
            }
        }

        stage('Push Backend Image') {
            steps {
                echo 'Pushing backend image to ECR...'

                sh '''
                    set -e

                    docker push ${BACKEND_REPOSITORY}:${IMAGE_TAG}
                    docker push ${BACKEND_REPOSITORY}:latest
                '''
            }
        }

        stage('Verify ECR Images') {
            steps {
                echo 'Verifying images in ECR...'

                sh '''
                    set -e

                    echo "Frontend images:"
                    aws ecr describe-images \
                        --repository-name streaming-frontend \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[*].imageTags' \
                        --output table

                    echo "Backend images:"
                    aws ecr describe-images \
                        --repository-name streaming-backend \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[*].imageTags' \
                        --output table
                '''
            }
        }
    }

    post {

        success {
            echo '''
=========================================
BUILD SUCCESSFUL
=========================================

Docker images were successfully
built and pushed to Amazon ECR.

=========================================
'''
        }

        failure {
            echo '''
=========================================
BUILD FAILED
=========================================

Check the Jenkins console output for
the stage that failed.

=========================================
'''
        }

        always {
            sh '''
                echo "Cleaning unused Docker images..."
                docker image prune -f || true
            '''
        }
    }
}
```

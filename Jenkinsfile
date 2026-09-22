pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '243747081594'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPOSITORY  = "${ECR_REGISTRY}/streaming-frontend"
        AUTH_REPOSITORY      = "${ECR_REGISTRY}/streaming-auth"
        ADMIN_REPOSITORY     = "${ECR_REGISTRY}/streaming-admin"
        CHAT_REPOSITORY      = "${ECR_REGISTRY}/streaming-chat"
        STREAMING_REPOSITORY = "${ECR_REGISTRY}/streaming-streaming"

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        /*
         * ==========================================
         * CHECKOUT
         * ==========================================
         */
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        /*
         * ==========================================
         * VERIFY TOOLS
         * ==========================================
         */
        stage('Verify Tools') {
            steps {
                sh '''
                    set -e

                    echo "========================================="
                    echo "Checking required tools"
                    echo "========================================="

                    git --version
                    docker --version
                    aws --version

                    echo ""
                    echo "AWS Identity:"
                    aws sts get-caller-identity

                    echo ""
                    echo "AWS Region:"
                    echo "${AWS_REGION}"
                '''
            }
        }

        /*
         * ==========================================
         * FRONTEND
         * ==========================================
         */
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

        /*
         * ==========================================
         * AUTH SERVICE
         * ==========================================
         */
        stage('Build Auth Image') {
            steps {
                echo 'Building auth service Docker image...'

                sh '''
                    set -e

                    docker build \
                        -f ./backend/authService/Dockerfile \
                        -t ${AUTH_REPOSITORY}:${IMAGE_TAG} \
                        -t ${AUTH_REPOSITORY}:latest \
                        ./backend/authService
                '''
            }
        }

        /*
         * ==========================================
         * ADMIN SERVICE
         * ==========================================
         */
        stage('Build Admin Image') {
            steps {
                echo 'Building admin service Docker image...'

                sh '''
                    set -e

                    docker build \
                        -f ./backend/adminService/Dockerfile \
                        -t ${ADMIN_REPOSITORY}:${IMAGE_TAG} \
                        -t ${ADMIN_REPOSITORY}:latest \
                        ./backend
                '''
            }
        }

        /*
         * ==========================================
         * CHAT SERVICE
         * ==========================================
         */
        stage('Build Chat Image') {
            steps {
                echo 'Building chat service Docker image...'

                sh '''
                    set -e

                    docker build \
                        -f ./backend/chatService/Dockerfile \
                        -t ${CHAT_REPOSITORY}:${IMAGE_TAG} \
                        -t ${CHAT_REPOSITORY}:latest \
                        ./backend
                '''
            }
        }

        /*
         * ==========================================
         * STREAMING SERVICE
         * ==========================================
         */
        stage('Build Streaming Image') {
            steps {
                echo 'Building streaming service Docker image...'

                sh '''
                    set -e

                    docker build \
                        -f ./backend/streamingService/Dockerfile \
                        -t ${STREAMING_REPOSITORY}:${IMAGE_TAG} \
                        -t ${STREAMING_REPOSITORY}:latest \
                        ./backend
                '''
            }
        }

        /*
         * ==========================================
         * ECR LOGIN
         * ==========================================
         */
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

        /*
         * ==========================================
         * PUSH FRONTEND
         * ==========================================
         */
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

        /*
         * ==========================================
         * PUSH AUTH
         * ==========================================
         */
        stage('Push Auth Image') {
            steps {
                echo 'Pushing auth image to ECR...'

                sh '''
                    set -e

                    docker push ${AUTH_REPOSITORY}:${IMAGE_TAG}
                    docker push ${AUTH_REPOSITORY}:latest
                '''
            }
        }

        /*
         * ==========================================
         * PUSH ADMIN
         * ==========================================
         */
        stage('Push Admin Image') {
            steps {
                echo 'Pushing admin image to ECR...'

                sh '''
                    set -e

                    docker push ${ADMIN_REPOSITORY}:${IMAGE_TAG}
                    docker push ${ADMIN_REPOSITORY}:latest
                '''
            }
        }

        /*
         * ==========================================
         * PUSH CHAT
         * ==========================================
         */
        stage('Push Chat Image') {
            steps {
                echo 'Pushing chat image to ECR...'

                sh '''
                    set -e

                    docker push ${CHAT_REPOSITORY}:${IMAGE_TAG}
                    docker push ${CHAT_REPOSITORY}:latest
                '''
            }
        }

        /*
         * ==========================================
         * PUSH STREAMING
         * ==========================================
         */
        stage('Push Streaming Image') {
            steps {
                echo 'Pushing streaming image to ECR...'

                sh '''
                    set -e

                    docker push ${STREAMING_REPOSITORY}:${IMAGE_TAG}
                    docker push ${STREAMING_REPOSITORY}:latest
                '''
            }
        }

        /*
         * ==========================================
         * VERIFY ECR
         * ==========================================
         */
        stage('Verify ECR Images') {
            steps {
                echo 'Verifying images in Amazon ECR...'

                sh '''
                    set -e

                    echo ""
                    echo "========================================="
                    echo "FRONTEND IMAGES"
                    echo "========================================="

                    aws ecr describe-images \
                        --repository-name streaming-frontend \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[*].imageTags' \
                        --output table

                    echo ""
                    echo "========================================="
                    echo "AUTH IMAGES"
                    echo "========================================="

                    aws ecr describe-images \
                        --repository-name streaming-auth \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[*].imageTags' \
                        --output table

                    echo ""
                    echo "========================================="
                    echo "ADMIN IMAGES"
                    echo "========================================="

                    aws ecr describe-images \
                        --repository-name streaming-admin \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[*].imageTags' \
                        --output table

                    echo ""
                    echo "========================================="
                    echo "CHAT IMAGES"
                    echo "========================================="

                    aws ecr describe-images \
                        --repository-name streaming-chat \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[*].imageTags' \
                        --output table

                    echo ""
                    echo "========================================="
                    echo "STREAMING IMAGES"
                    echo "========================================="

                    aws ecr describe-images \
                        --repository-name streaming-streaming \
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
=============================================
        STREAMINGAPP BUILD SUCCESSFUL
=============================================

Docker images successfully built and pushed
to Amazon ECR.

Images:

1. streaming-frontend
2. streaming-auth
3. streaming-admin
4. streaming-chat
5. streaming-streaming

=============================================
'''
        }

        failure {
            echo '''
=============================================
        STREAMINGAPP BUILD FAILED
=============================================

Check the Jenkins console output for the
stage that failed.

=============================================
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

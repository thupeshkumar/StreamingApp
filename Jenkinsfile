pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '243747081594'

        FRONTEND_REPO =
            "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-frontend"

        BACKEND_REPO =
            "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-backend"

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                    docker build \
                    -t ${FRONTEND_REPO}:${IMAGE_TAG} \
                    ./frontend
                '''
            }
        }

        stage('Build Backend') {
            steps {
                sh '''
                    docker build \
                    -t ${BACKEND_REPO}:${IMAGE_TAG} \
                    ./backend
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password \
                    --region ${AWS_REGION} |
                    docker login \
                    --username AWS \
                    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
            }
        }

        stage('Push Frontend') {
            steps {
                sh '''
                    docker push ${FRONTEND_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Push Backend') {
            steps {
                sh '''
                    docker push ${BACKEND_REPO}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo 'Docker images successfully pushed to ECR.'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}

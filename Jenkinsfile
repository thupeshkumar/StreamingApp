 pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ACCOUNT_ID = credentials('243747081594')   // Store your AWS Account ID in Jenkins credentials
        IMAGE_TAG = "latest"
        ECR_REGISTRY = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streamingapp"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/<your-username>/StreamingApp.git'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Build & Push Images') {
            steps {
                script {
                    def services = [
                        [name: "frontend", path: "frontend"],
                        [name: "auth", path: "backend/authService"],
                        [name: "streaming", path: "backend/streamingService"],
                        [name: "admin", path: "backend/adminService"],
                        [name: "chat", path: "backend/chatService"]
                    ]

                    services.each { svc ->
                        sh """
                        echo "Building ${svc.name}..."
                        docker build -t streamingapp/${svc.name}:$IMAGE_TAG ${svc.path}

                        echo "Tagging ${svc.name}..."
                        docker tag streamingapp/${svc.name}:$IMAGE_TAG \
                          $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/streamingapp/${svc.name}:$IMAGE_TAG

                        echo "Pushing ${svc.name}..."
                        docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/streamingapp/${svc.name}:$IMAGE_TAG
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS with Helm') {
            steps {
                sh '''
                helm upgrade --install streamingapp charts/streamingapp \
                  --namespace streamingapp \
                  --create-namespace \
                  --set global.imageTag=$IMAGE_TAG \
                  --set services.frontend.image.repository=$ECR_REGISTRY/frontend \
                  --set services.auth.image.repository=$ECR_REGISTRY/auth \
                  --set services.streaming.image.repository=$ECR_REGISTRY/streaming \
                  --set services.admin.image.repository=$ECR_REGISTRY/admin \
                  --set services.chat.image.repository=$ECR_REGISTRY/chat \
                  --set secrets.jwtSecret="replace-with-a-strong-secret" \
                  --set aws.region=$AWS_REGION \
                  --set aws.s3Bucket="your-s3-bucket-name"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment succeeded!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}

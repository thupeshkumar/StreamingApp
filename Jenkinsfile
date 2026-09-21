pipeline {
    agent any

    environment {
        AWS_REGION        = "us-east-1"
        IMAGE_TAG         = "latest"
        AWS_ACCOUNT_ID    = "243747081594"
        AWS_ACCESS_KEY_ID = "AKIATRQDVJV5LDMPPMMV"   // Not recommended to hardcode, better to use Jenkins credentials
        ECR_BASE_URL      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/thupeshkumar/StreamingApp.git'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin $ECR_BASE_URL
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
                          $ECR_BASE_URL/streamingapp/${svc.name}:$IMAGE_TAG

                        echo "Pushing ${svc.name}..."
                        docker push $ECR_BASE_URL/streamingapp/${svc.name}:$IMAGE_TAG
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
                  --set services.frontend.image.repository=$ECR_BASE_URL/streamingapp/frontend \
                  --set services.auth.image.repository=$ECR_BASE_URL/streamingapp/auth \
                  --set services.streaming.image.repository=$ECR_BASE_URL/streamingapp/streaming \
                  --set services.admin.image.repository=$ECR_BASE_URL/streamingapp/admin \
                  --set services.chat.image.repository=$ECR_BASE_URL/streamingapp/chat \
                  --set secrets.jwtSecret="replace-with-a-strong-secret" \
                  --set aws.region=$AWS_REGION \
                  --set aws.s3Bucket="streamingapp-bucket1"
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

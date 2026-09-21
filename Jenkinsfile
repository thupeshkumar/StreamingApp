pipeline {
    agent any

    environment {
        AWS_REGION        = "us-east-1"
        IMAGE_TAG         = "latest"
        AWS_ACCOUNT_ID    = "243747081594"
        AWS_ACCESS_KEY_ID = "AKIATRQDVJV5LDMPPMMV"
        ECR_BASE_URL      = "://amazonaws.com"
        ECR_REGISTRY      = "${ECR_BASE_URL}/streamingapp"
    }

    stages {
        // 🚀 Redundant 'Checkout Code' stage removed entirely to prevent Git 128 Errors.
        
        stage('Login to ECR') {
            steps {
                withCredentials([string(credentialsId: 'Thupesh-aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BASE_URL'
                }
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

                    withCredentials([string(credentialsId: 'Thupesh-aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        services.each { svc ->
                            sh """
                            echo "Building ${svc.name}..."
                            docker build -t streamingapp/${svc.name}:${IMAGE_TAG} ${svc.path}

                            echo "Tagging ${svc.name}..."
                            docker tag streamingapp/${svc.name}:${IMAGE_TAG} ${ECR_BASE_URL}/streamingapp/${svc.name}:${IMAGE_TAG}

                            echo "Pushing ${svc.name}..."
                            docker push ${ECR_BASE_URL}/streamingapp/${svc.name}:${IMAGE_TAG}
                            """
                        }
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

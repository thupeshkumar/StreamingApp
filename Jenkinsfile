pipeline {
    agent any

    environment {
        AWS_REGION        = "us-east-1"
        IMAGE_TAG         = "latest"
        AWS_ACCOUNT_ID    = "243747081594"
        AWS_ACCESS_KEY_ID = "AKIATRQDVJV5LDMPPMMV"
        ECR_BASE_URL      = "243747081594.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REGISTRY      = "://amazonaws.com"
    }

    stages {
        stage('Login to ECR') {
            steps {
                withCredentials([string(credentialsId: 'Thupesh-aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    // Hardcoded plain string target eliminates variable scope failure entirely
                    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 243747081594.dkr.ecr.us-east-1.amazonaws.com'
                }
            }
        }

        stage('Build & Push Images') {
            steps {
                script {
                    def services = [
                        [name: "frontend",  context: ".",                     dockerfile: "frontend/Dockerfile"],
                        [name: "auth",      context: "backend",               dockerfile: "backend/authService/Dockerfile"],
                        [name: "streaming", context: "backend",               dockerfile: "backend/streamingService/Dockerfile"],
                        [name: "admin",     context: "backend",               dockerfile: "backend/adminService/Dockerfile"],
                        [name: "chat",      context: "backend",               dockerfile: "backend/chatService/Dockerfile"]
                    ]

                    withCredentials([string(credentialsId: 'Thupesh-aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        services.each { svc ->
                            sh """
                            echo "Building ${svc.name} using context ${svc.context} and file ${svc.dockerfile}..."
                            docker build -t streamingapp/${svc.name}:${IMAGE_TAG} -f ${svc.dockerfile} ${svc.context}

                            echo "Tagging ${svc.name}..."
                            docker tag streamingapp/${svc.name}:${IMAGE_TAG} ://amazonaws.com/${svc.name}:${IMAGE_TAG}

                            echo "Pushing ${svc.name}..."
                            docker push ://amazonaws.com/${svc.name}:${IMAGE_TAG}
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy to EKS with Helm') {
            steps {
                // Typo fixed: changed from ${ECR_REGISTRY/auth} to ${ECR_REGISTRY}/auth
                sh """
                helm upgrade --install streamingapp charts/streamingapp \
                  --namespace streamingapp \
                  --create-namespace \
                  --set global.imageTag=${IMAGE_TAG} \
                  --set services.frontend.image.repository=${ECR_REGISTRY}/frontend \
                  --set services.auth.image.repository=${ECR_REGISTRY}/auth \
                  --set services.streaming.image.repository=${ECR_REGISTRY}/streaming \
                  --set services.admin.image.repository=${ECR_REGISTRY}/admin \
                  --set services.chat.image.repository=${ECR_REGISTRY}/chat \
                  --set secrets.jwtSecret="replace-with-a-strong-secret" \
                  --set aws.region=${AWS_REGION} \
                  --set aws.s3Bucket="streamingapp-bucket1"
                """
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

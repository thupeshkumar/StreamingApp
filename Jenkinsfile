pipeline {
    agent any

    environment {
        AWS_REGION     = "us-east-1"
        IMAGE_TAG      = "latest"
        AWS_ACCOUNT_ID = "243747081594"
        ECR_BASE_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
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
                withAWS(credentials: 'Thupesh-aws-jenkins', region: "${AWS_REGION}") {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin $ECR_BASE_URL
                    '''
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

                    services.each { svc ->
                        sh """
                        docker build -t streamingapp/${svc.name}:$IMAGE_TAG ${svc.path}
                        docker tag streamingapp/${svc.name}:$IMAGE_TAG \
                          $ECR_BASE_URL/streamingapp/${svc.name}:$IMAGE_TAG
                        docker push $ECR_BASE_URL/streamingapp/${svc.name}:$IMAGE_TAG
                        """
                    }
                }
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

pipeline {
    agent any

    environment {
        AWS_REGION     = "us-east-1"
        IMAGE_TAG      = "latest"
        // Replace this with your literal 12-digit AWS Account ID directly
        AWS_ACCOUNT_ID = "AKIATRQDVJV5LDMPPMMV" 
        ECR_REGISTRY   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streamingapp"
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
                // This wrapper injects the underlying AWS keys securely into your shell environment
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'AKIATRQDVJV5LDMPPMMV', 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    // Use single quotes so the Linux shell securely expands the environment variables
                    sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com'
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

                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: 'Thupesh-aws-jenkins', 
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        services.each { svc ->
                            sh """
                            echo "Building ${svc.name}..."
                            docker build -t streamingapp/${svc.name}:${IMAGE_TAG} ${svc.path}

                            echo "Tagging ${svc.name}..."
                            docker tag streamingapp/${svc.name}:${IMAGE_TAG} \
                              ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}://{svc.name}:${IMAGE_TAG}

                            echo "Pushing ${svc.name}..."
                            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}://{svc.name}:${IMAGE_TAG}
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy to EKS with Helm') {
            steps {
                // Make sure your Jenkins host context has a configured ~/.kube/config file to authenticate with EKS
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

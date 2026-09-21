 pipeline {
  agent any

  environment {
    
    AWS_REGION = 'us-east-1'
    ECR_PREFIX = 'streamingapp'
    RELEASE_NAME = 'streamingapp'
    K8S_NAMESPACE = 'streamingapp'
    AWS_CREDENTIALS_ID = 'Thupesh-aws-jenkins'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {

    stage('Check Tools') {
      steps {
        sh 'echo $PATH'
        sh 'which aws'
        sh 'aws --version'
        sh 'which docker'
        sh 'docker --version'
        sh 'which kubectl'
        sh 'kubectl version --client'
        sh 'which helm'
        sh 'helm version'
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.IMAGE_TAG = sh(
            returnStdout: true,
            script: 'git rev-parse --short=12 HEAD'
          ).trim()
        }
      }
    }

    stage('AWS Login') {
      steps {
        script {
          withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: env.AWS_CREDENTIALS_ID]
          ]) {

            env.AWS_ACCOUNT_ID = sh(
              returnStdout: true,
              script: 'aws sts get-caller-identity --query Account --output text'
            ).trim()

            env.ECR_REGISTRY = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"

            sh '''
              aws ecr get-login-password --region "$AWS_REGION" \
              | docker login --username AWS --password-stdin "$ECR_REGISTRY"
            '''
          }
        }
      }
    }

    stage('Create ECR Repositories') {
      steps {
        script {
          withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: env.AWS_CREDENTIALS_ID]
          ]) {

            sh 'bash scripts/create-ecr-repos.sh'
          }
        }
      }
    }

    stage('Build and Push Images') {
      steps {
        script {

          def services = [
            [name: 'frontend', context: 'frontend', dockerfile: 'Dockerfile'],
            [name: 'auth', context: 'backend/authService', dockerfile: 'Dockerfile'],
            [name: 'streaming', context: 'backend', dockerfile: 'streamingService/Dockerfile'],
            [name: 'admin', context: 'backend', dockerfile: 'adminService/Dockerfile'],
            [name: 'chat', context: 'backend', dockerfile: 'chatService/Dockerfile']
          ]

          services.each { svc ->

            def image = "${env.ECR_REGISTRY}/${env.ECR_PREFIX}/${svc.name}:${env.IMAGE_TAG}"

            sh """
              docker build \
              -t ${image} \
              -f ${svc.context}/${svc.dockerfile} \
              ${svc.context}
            """

            sh "docker push ${image}"
          }
        }
      }
    }

    stage('Deploy to EKS') {

      when {
        branch 'main'
      }

      steps {
        script {

          withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: env.AWS_CREDENTIALS_ID]
          ]) {

            sh '''
              helm upgrade --install "$RELEASE_NAME" charts/streamingapp \
                --namespace "$K8S_NAMESPACE" \
                --create-namespace \
                --set services.frontend.image.repository="$ECR_REGISTRY/$ECR_PREFIX/frontend" \
                --set services.auth.image.repository="$ECR_REGISTRY/$ECR_PREFIX/auth" \
                --set services.streaming.image.repository="$ECR_REGISTRY/$ECR_PREFIX/streaming" \
                --set services.admin.image.repository="$ECR_REGISTRY/$ECR_PREFIX/admin" \
                --set services.chat.image.repository="$ECR_REGISTRY/$ECR_PREFIX/chat" \
                --set global.imageTag="$IMAGE_TAG"
            '''
          }
        }
      }
    }
  }

  post {

    success {
      sh '''
        if [ -n "${SNS_TOPIC_ARN:-}" ]; then
          aws sns publish \
            --topic-arn "$SNS_TOPIC_ARN" \
            --message "Streaming app deployment succeeded: $JOB_NAME #$BUILD_NUMBER ($IMAGE_TAG)"
        fi
      '''
    }

    failure {
      sh '''
        if [ -n "${SNS_TOPIC_ARN:-}" ]; then
          aws sns publish \
            --topic-arn "$SNS_TOPIC_ARN" \
            --message "Streaming app deployment failed: $JOB_NAME #$BUILD_NUMBER"
        fi
      '''
    }
  }
}

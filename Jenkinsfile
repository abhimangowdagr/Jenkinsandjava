pipeline {
    agent { label 'Java_Agent1' }

    environment {
        // UPDATED: Based on your screenshot
        AWS_REGION = 'ap-south-1' 
        ECR_REPO_URI = '://966376172086.dkr.ecr.ap-south-1.amazonaws.com'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        IMAGE_URI = "${ECR_REPO_URI}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Java App') {
            steps {
                sh 'mvn clean -B -Denforcer.skip=true package'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                // Ensure 'aws-creds' exists in Jenkins -> Credentials
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                        echo "Logging in to Private ECR in Mumbai region..."
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin 966376172086.dkr.ecr.ap-south-1.amazonaws.com
                    '''
                }
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_URI} ."
                sh "docker tag ${IMAGE_URI} ${ECR_REPO_URI}:latest"
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push ${IMAGE_URI}"
                sh "docker push ${ECR_REPO_URI}:latest"
            }
        }
    }

    post {
        success {
            echo "✅ Image pushed successfully: ${IMAGE_URI}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}

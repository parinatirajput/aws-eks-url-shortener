pipeline {

    agent any

    environment {

        AWS_REGION = "us-east-2"
        CLUSTER_NAME = "url-shortener-cluster"

        IMAGE_NAME = "parinati/url-shortener"
        IMAGE_TAG = "${BUILD_NUMBER}"

        HELM_RELEASE = "url-shortener"
        HELM_CHART = "helm/url-shortener"

        NAMESPACE = "url-shortener"

        TF_DIR = "terraform"
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Configure kubectl') {
            steps {

                sh """
                aws eks update-kubeconfig \
                --region ${AWS_REGION} \
                --name ${CLUSTER_NAME}
                """

                sh "kubectl get nodes"
            }
        }

        stage('Build Docker Image') {

            steps {

                sh """
                docker build \
                -t ${IMAGE_NAME}:${IMAGE_TAG} \
                app/
                """
            }
        }

        stage('Push Docker Image') {

            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    docker push ${IMAGE_NAME}:${IMAGE_TAG}

                    docker logout
                    '''
                }

            }
        }

        stage('Deploy to EKS') {

            steps {

                sh """
                helm upgrade --install ${HELM_RELEASE} ${HELM_CHART} \
                  --namespace ${NAMESPACE} \
                  --create-namespace \
                  --set image.repository=${IMAGE_NAME} \
                  --set image.tag=${IMAGE_TAG}
                """

            }
        }

        stage('Verify Deployment') {

            steps {

                sh """
                kubectl rollout status deployment/url-shortener \
                -n ${NAMESPACE}
                """

                sh """
                kubectl get pods -n ${NAMESPACE}
                """

                sh """
                kubectl get svc -n ${NAMESPACE}
                """
            }
        }
    }

    post {

        success {

            echo "======================================"
            echo "Deployment Successful"
            echo "======================================"

        }

        failure {

            echo "======================================"
            echo "Deployment Failed"
            echo "======================================"

        }

        always {

            cleanWs()

        }
    }

}

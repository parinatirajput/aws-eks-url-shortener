pipeline {
    agent any

    environment {

        IMAGE_NAME = "parinati/url-shortener"
        IMAGE_TAG = "${BUILD_NUMBER}"

        AWS_REGION = "us-east-2"

        CLUSTER_NAME = "url-shortener-cluster"

        HELM_RELEASE = "url-shortener"
        HELM_CHART = "helm/url-shortener"
        NAMESPACE = "url-shortener"

        KUBECONFIG = "/var/lib/jenkins/.kube/config"
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

    stage('Check Application Changes') {
    steps {
        script {

            def changedFiles = sh(
                script: 'git diff --name-only HEAD~1 HEAD',
                returnStdout: true
            ).trim()

            echo "Changed files:\n${changedFiles}"

            def appChanged = false

            changedFiles.split('\n').each { file ->
                if (file.startsWith('app/') ||
                    file.startsWith('helm/') ||
                    file.startsWith('kubernetes/') ||
                    file == 'Dockerfile') {

                    appChanged = true
                }
            }

            if (!appChanged) {
                currentBuild.result = 'NOT_BUILT'
                error('No application changes detected. Skipping Application Pipeline.')
            }

            echo "Application changes found. Continuing..."
        }
    }
}
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build \
                -t ${IMAGE_NAME}:${IMAGE_TAG} \
                app/
                '''
            }
        }

        stage('Docker Login') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login \
                    -u "$DOCKER_USER" \
                    --password-stdin
                    '''

                }
            }
        }

        stage('Push Docker Image') {
            steps {

                sh '''
                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                docker push ${IMAGE_NAME}:latest
                '''

            }
        }

        stage('Update kubeconfig') {
            steps {

                sh '''
                aws eks update-kubeconfig \
                --region ${AWS_REGION} \
                --name ${CLUSTER_NAME}
                '''

            }
        }

        stage('Deploy using Helm') {

            steps {

                sh '''
                helm upgrade --install ${HELM_RELEASE} ${HELM_CHART} \
                --namespace ${NAMESPACE} \
                --create-namespace \
                --set image.repository=${IMAGE_NAME} \
                --set image.tag=${IMAGE_TAG}
                '''

            }

        }

        stage('Verify Deployment') {

            steps {

                sh '''
                kubectl rollout status deployment/url-shortener \
                -n ${NAMESPACE}

                kubectl get pods -n ${NAMESPACE}

                kubectl get svc -n ${NAMESPACE}
                '''

            }

        }
    }

    post {

        success {
            echo 'Application deployed successfully.'
        }

        failure {
            echo 'Application deployment failed.'
        }

        always {
            cleanWs()
        }

    }

}

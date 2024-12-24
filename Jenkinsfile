pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'einavgo'
        IMAGE_TAG = "${env.BUILD_NUMBER}" // Unique tag per build
        KEY_PATH = '/home/ubuntu/.ssh/id_rsa'
        GIT_SSH_COMMAND = 'ssh -i /home/ubuntu/.ssh/id_rsa -o StrictHostKeyChecking=yes'
    }

    stages {
        stage('Process Each Service') {
            steps {
                script {
                    def services = [
                        [name: 'kafka', ec2_ip: '16.16.49.216', ec2_user: 'ubuntu', path: 'services/kafka']
                    ]

                    def parallelStages = [:]

                    services.each { service ->
                        parallelStages["Build and Deploy - ${service.name}"] = {
                            script {
                                echo "Processing service: ${service.name}..."

                                stage("Clean Workspace - ${service.name}") {
                                    echo "Cleaning repository for ${service.name}..."
                                    deleteDir()
                                }

                                stage("Clone Repository - ${service.name}") {
                                    echo "Cloning repository for ${service.name}..."
                                    git branch: 'main', url: 'git@github.com:EinavGo/OptiLog.git', credentialsId: '3dd08245-d374-452a-b539-7d7ab16f92d9'
                                }

                                stage("Build Docker Image - ${service.name}") {
                                    echo "Building Docker image for ${service.name}..."
                                    sh """
                                    docker build -t ${DOCKERHUB_USERNAME}/${service.name}:${IMAGE_TAG} ${service.path}
                                    """
                                }

                                stage("Push Docker Image - ${service.name}") {
                                    echo "Pushing Docker image for ${service.name} to DockerHub..."
                                    withCredentials([string(credentialsId: 'dockerhub-password', variable: 'DOCKERHUB_PASSWORD')]) {
                                        sh """
                                        echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                                        docker push ${DOCKERHUB_USERNAME}/${service.name}:${IMAGE_TAG}
                                        """
                                    }
                                }

                                stage("Deploy to EC2 - ${service.name}") {
                                    echo "Deploying ${service.name} to EC2 instance at ${service.ec2_ip}..."
                                    sh """
                                    scp -i ${KEY_PATH} -o StrictHostKeyChecking=no ${service.path}/docker-compose.yml ${service.ec2_user}@${service.ec2_ip}:/home/${service.ec2_user}/
                                    ssh -i ${KEY_PATH} -o StrictHostKeyChecking=no ${service.ec2_user}@${service.ec2_ip} \\
                                    'cd /home/${service.ec2_user} && sudo docker-compose down && sudo docker-compose up -d'
                                    """
                                }
                            }
                        }
                    }

                    parallel parallelStages
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed for all services!'
        }
    }
}

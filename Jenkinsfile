pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'einavgo'
        IMAGE_TAG = "${env.BUILD_NUMBER}" // Unique tag per build
        KEY_PATH = '/home/ubuntu/.ssh/id_rsa'
    }

    stages {
        stage('Process Each Service') {
            steps {
                script {
                    // Define list of services with paths and EC2 details
                    def services = [
                        [name: 'kafka', ec2_ip: '16.16.49.216', ec2_user: 'ubuntu', path: 'services/kafka'],
                    ]

                    // Run services in parallel
                    def parallelStages = [:]

                    for (service in services) {
                        parallelStages["Build and Deploy - ${service.name}"] = {
                            stage("Check Changes - ${service.name}") {
                                when {
                                    changeset "services/${service.name}/**"
                                }
                                steps {
                                    echo "Changes detected for ${service.name}..."
                                }
                            }

                            stage("Clone Repository - ${service.name}") {
                                steps {
                                    echo "Cloning repository for ${service.name}..."
                                    sh "rm -rf ${service.path}"  // Clean workspace
                                    git branch: 'main', url: 'git@github.com:EinavGo/OptiLog.git', credentialsId: '8e7bc9be-e10d-43d1-8931-1d938880ccc0'
                                }
                            }

                            stage("Build Docker Image - ${service.name}") {
                                steps {
                                    echo "Building Docker image for ${service.name}..."
                                    sh """
                                    docker build -t ${DOCKERHUB_USERNAME}/${service.name}:${IMAGE_TAG} ${service.path}
                                    """
                                }
                            }

                            stage("Push Docker Image - ${service.name}") {
                                steps {
                                    echo "Pushing Docker image for ${service.name} to DockerHub..."
                                    withCredentials([string(credentialsId: 'dockerhub-password', variable: 'DOCKERHUB_PASSWORD')]) {
                                        sh """
                                        echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin
                                        docker push ${DOCKERHUB_USERNAME}/${service.name}:${IMAGE_TAG}
                                        """
                                    }
                                }
                            }

                            stage("Deploy to EC2 - ${service.name}") {
                                steps {
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

                    // Execute all service builds and deployments in parallel
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

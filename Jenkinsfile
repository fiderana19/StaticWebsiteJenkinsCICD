pipeline{
    environment{
        IMAGE_NAME = "static_website"
        APP_CONTAINER_PORT = "80"
        APP_EXPOSED_PORT = "9999"
        IMAGE_TAG = "latest"
        STAGING = "fideo_staging"
        PRODUCTION = "fideo_prod"
        DOCKERHUB_ID = "fiderana19"
        DOCKERHUB_PASSWORD = credentials('dockerhub_password')
    }
    agent none
    
    stages{
        stage('Checking docker') {
            agent any
            steps {
                sh 'docker --version'
            }
        }
        stage("Build image"){
            agent any
            steps{
                script{
                    sh '''
                        docker build -t ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG .
                    '''
                }
            }
        }
        stage("Run container based on builded image"){
            agent any
            steps{
                script{
                    sh '''
                        echo "Cleaning existing container if exists"
                        docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                        docker run -d --name $IMAGE_NAME -p $APP_EXPOSED_PORT:$APP_CONTAINER_PORT ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                    '''
                }
            }
        }
        stage("Test image"){
            agent any
            steps{
                script{
                    sh '''
                        docker ps
                        curl http://host.docker.internal:$APP_EXPOSED_PORT | grep -i "Dimension"                    
                    '''
                }
            }
        }
        stage("Clean container"){
            agent any
            steps{
                script{
                    sh '''
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME
                    '''
                }
            }
        }
        stage("Login and pushing the image on Docker Hub"){
            agent any
            steps{
                script{
                    sh '''
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                        docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
        stage("Push image in staging and deploy it"){
            when{
                expression { env.BRANCH_NAME == 'main' }
            }
            agent{
                docker {
                    image 'franela/dind'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps{
                script{
                    sh '''
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                        docker image tag ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG-staging
                        docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG:$IMAGE_TAG-staging
                    '''
                }
            }
        }
        stage("Push image in production and deploy it"){
            when{
                expression { env.BRANCH_NAME == 'main' }
            }
            agent{
                docker {
                    image 'franela/dind'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps{
                script{
                    sh '''
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                        docker image tag ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG-prod
                        docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG:$IMAGE_TAG-prod
                    '''
                }
            }
        }        
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}

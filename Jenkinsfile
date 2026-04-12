pipeline{
    environment{
        IMAGE_NAME = "static_website"
        APP_CONTAINER_PORT = "80"
        APP_EXPOSED_PORT = "80"
        IMAGE_TAG = ""
        STAGING = ""
        PRODUCTION = ""
        DOCKERHUB_ID = ""
        DOCKERHUB_PASSWORD = ""
    }
    agent none
    stages{
        stage("Build image"){
            agent any
            steps{
                script{
                    sh ```
                        docker build -t ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG .
                    ```
                }
            }
        }
        stage("Run container based on builded image"){
            agent any
            steps{
                script{
                    sh ```
                        echo "Cleaning existing container if exists"
                        docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                        docker run -d --name $IMAGE_NAME -p $APP_EXPOSED_PORT:$APP_CONTAINER_PORT -e PORT=$APP_CONTAINER_PORT ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                    ```
                }
            }
        }
        stage("Test image"){
            agent any
            steps{
                script{
                    sh ```
                        curl localhost | grep -i "Dimension"                    
                    ```
                }
            }
        }
        stage("Clean container"){
            agent any
            steps{
                script{
                    sh ```
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME
                    ```
                }
            }
        }
        stage("Login and pushing the image on Docker Hub"){
            agent any
            steps{
                script{
                    sh ```
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                        docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
                    ```
                }
            }
        }
        stage("Push image in staging and deploy it"){
            when{
                expression ( GIT_BRANCH === "origin/main" )
            }
            agent{
                docker ( image 'franela/dind' )
            }
            environment{
                HEROKU_API_KEY = credentials("heroku_api_key")
            }
            steps{
                script{
                    sh ```
                        apk --no-cache add npm
                        npm install -g heroku
                        heroku container:login
                        heroku create $STAGING || echo "Project already exist"
                        heroku container:push -a $STAGING web
                        heroku container:release -a $STAGING web                        
                    ```
                }
            }
        }
        stage("Push image in production and deploy it"){
            when{
                expression ( GIT_BRANCH === "origin/main" )
            }
            agent{
                docker ( image 'franela/dind' )
            }
            environment{
                HEROKU_API_KEY = credentials("heroku_api_key")
            }
            steps{
                script{
                    sh ```
                        apk --no-cache add npm
                        npm install -g heroku
                        heroku container:login
                        heroku create $PRODUCTION || echo "Project already exist"
                        heroku container:push -a $PRODUCTION web
                        heroku container:release -a $PRODUCTION web                        
                    ```
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
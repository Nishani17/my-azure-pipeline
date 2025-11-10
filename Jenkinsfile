pipeline {
    agent any // This means "run on any available Jenkins machine"

    // --- CONFIGURATION ---
    // This is where we store our secret values
    environment {
        // !! YOU MUST EDIT THIS !!
        // Paste your Container Registry name from Step 1C
        ACR_NAME           = "myuniqueacrnish1011"  

        // !! YOU MUST EDIT THIS !!
        // Paste your App Service Webhook URL from Step 1E
        WEBHOOK_URL        = "https://$myuniqueappnish1110:RZmiLBuTi6FYJikMGCsChwoBXWAm5m3mlrEoRwNBFdm9sCRyEP4Es4muynbF@myuniqueappnish1110-avbyemh2gxh2eghm.scm.malaysiawest-01.azurewebsites.net/api/registry/webhook" 

        IMAGE_NAME         = "my-web-app"
        ACR_CREDS_ID       = "acr-creds" // The 'nickname' we will create in Jenkins
    }
    // ---------------------

    stages { // The list of steps for the chef

        stage('Checkout') { // Step 1: Get the code
            steps { 
                checkout scm // This checks out the code from this GitHub repo
            }
        }

        stage('Build & Test') { // Step 2: Install dependencies and test
            steps {
                docker.image('node:18-alpine').inside {
                    sh 'npm install' // Runs 'npm install' inside a Node container
                    sh 'npm test'    // Runs the 'test' script from package.json
                }
            }
        }

        stage('Build & Push to ACR') { // Step 3: Build the Docker image and push to Azure
            steps {
                script {
                    // Create unique names for the image
                    def fullImageTag = "${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:build-${env.BUILD_NUMBER}"
                    def latestImageTag = "${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:latest"

                    sh "docker build -t ${fullImageTag} -t ${latestImageTag} ." // Build the image

                    // Log in to Azure and push the image
                    docker.withRegistry("https://${env.ACR_NAME}.azurecr.io", env.ACR_CREDS_ID) {
                        sh "docker push ${fullImageTag}"
                        sh "docker push ${latestImageTag}"
                    }
                }
            }
        }

        stage('Deploy to Azure') { // Step 4: Tell Azure to deploy the new image
            steps {
                // This "pings" the secret URL and tells Azure to pull the :latest image
                sh "curl -X POST '${env.WEBHOOK_URL}'"
            }
        }
    }
}

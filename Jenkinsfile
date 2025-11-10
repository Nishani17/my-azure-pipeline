pipeline {
    agent any // Run on any available agent

    // --- CONFIGURATION ---
    // !! CHANGE THESE VALUES !!
    environment {
        // Paste your Container Registry name from Step 1C
        ACR_NAME           = "myuniqueacrnish1011"  // <-- EDIT THIS
        // Paste your App Service Webhook URL from Step 1E
        WEBHOOK_URL        = "https://$myuniqueappnish1110:RZmiLBuTi6FYJikMGCsChwoBXWAm5m3mlrEoRwNBFdm9sCRyEP4Es4muynbF@myuniqueappnish1110-avbyemh2gxh2eghm.scm.malaysiawest-01.azurewebsites.net/api/registry/webhook" // <-- EDIT THIS
        
        // Paste your ACR Username (which is your ACR_NAME)
        ACR_USERNAME       = "myuniqueacrnish1011" // <-- EDIT THIS
        
        IMAGE_NAME         = "my-web-app"
        ACR_PASSWORD_ID    = "acr-password" // The 'Secret Text' ID we just made
    }
    // ---------------------

    stages {
        stage('Checkout') {
            steps { 
                checkout scm 
            }
        }
        
        stage('Build & Test') {
            steps {
                // We will run all docker commands manually
                // This builds a temporary image to run 'npm install'
                sh "docker build -t my-app-builder -f Dockerfile.build ."
                // This runs the test script inside the new builder image
                sh "docker run my-app-builder" // This runs the CMD ["npm", "test"]
            }
        }

        stage('Build & Push to ACR') {
            steps {
                script {
                    // Define the unique tags for this build
                    def fullImageTag = "${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:build-${env.BUILD_NUMBER}"
                    def latestImageTag = "${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:latest"
                    
                    // Build the final production image (uses the main Dockerfile)
                    sh "docker build -t ${fullImageTag} -t ${latestImageTag} ."
                    
                    // Use the 'acr-password' secret text to log in
                    // This is a plain shell command, it needs no plugins
                    withCredentials([string(credentialsId: env.ACR_PASSWORD_ID, variable: 'ACR_PASSWORD')]) {
                        sh "echo $ACR_PASSWORD | docker login ${env.ACR_NAME}.azurecr.io -u ${env.ACR_USERNAME} --password-stdin"
                    }
                    
                    // Push the images
                    sh "docker push ${fullImageTag}"
                    sh "docker push ${latestImageTag}"
                }
            }
        }

        stage('Deploy to Azure') {
            steps {
                // This step is the same and requires NO PLUGINS
                sh "curl -X POST '${env.WEBHOOK_URL}'"
            }
        }
    }
}

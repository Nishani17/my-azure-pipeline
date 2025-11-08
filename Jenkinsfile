pipeline {
    agent any

    // --- CONFIGURATION ---
    // !! CHANGE THESE VALUES !!
    environment {
        // Paste your Container Registry name from Step 1
        ACR_NAME           = "myuniqueacrb7bc6d0a"  // <-- EDIT THIS
        // Paste your App Service name from Step 1
        APP_SERVICE_NAME   = "my-unique-app-aed580fc" // <-- EDIT THIS
        // Paste your Resource Group name from Step 1
        RESOURCE_GROUP     = "my-cicd-rg" // <-- This is already correct
        // The name for your Docker image
        IMAGE_NAME         = "my-web-app"
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
                docker.image('node:18-alpine').inside {
                    sh 'echo "--- Installing Dependencies ---"'
                    sh 'npm install'
                    sh 'echo "--- Running Tests ---"'
                    sh 'npm test'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def fullImageTag = "${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:build-${env.BUILD_NUMBER}"
                    def latestImageTag = "${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:latest"
                    sh "docker build -t ${fullImageTag} -t ${latestImageTag} ."
                    env.FULL_IMAGE_TAG = fullImageTag
                }
            }
        }
        stage('Login to ACR & Push Image') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: 'azure-sp',
                                                       subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                                                       clientIdVariable: 'AZURE_CLIENT_ID',
                                                       clientSecretVariable: 'AZURE_CLIENT_SECRET',
                                                       tenantIdVariable: 'AZURE_TENANT_ID')]) {

                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
                    sh 'az acr login --name $ACR_NAME'
                    sh "docker push ${env.FULL_IMAGE_TAG}"
                    sh "docker push ${env.ACR_NAME}.azurecr.io/${env.IMAGE_NAME}:latest"
                }
            }
        }
        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: 'azure-sp',
                                                       subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                                                       clientIdVariable: 'AZURE_CLIENT_ID',
                                                       clientSecretVariable: 'AZURE_CLIENT_SECRET',
                                                       tenantIdVariable: 'AZURE_TENANT_ID')]) {

                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
                    sh "az webapp config container set --name ${env.APP_SERVICE_NAME} --resource-group ${env.RESOURCE_GROUP} --docker-custom-image-name ${env.FULL_IMAGE_TAG}"
                    sh "az webapp restart --name ${env.APP_SERVICE_NAME} --resource-group ${env.RESOURCE_GROUP}"
                }
            }
        }
    }
}

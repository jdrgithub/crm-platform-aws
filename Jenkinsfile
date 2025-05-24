pipeline {
  agent {
    dockerContainer {
      image 'jdrdock/jenkins-terraform'
      label 'latest'
      registryUrl 'https://index.docker.io/v1/'
      registryCredentialsId 'dockerhub-creds'
    }
  }

  stages {
    stage('Terraform Init') {
      steps {
        sh 'terraform version'
        sh 'terraform init'
      }
    }
  }
}

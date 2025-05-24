pipeline {
  agent {
    dockerContainer {
      image 'jdrdock/jenkins-terraform:latest'
      dockerHost 'https://index.docker.io/v1/'
      credentialsId 'dockerhub-creds'
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

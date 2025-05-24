pipeline {
  agent {
    dockerContainer {
      image 'jdrdock/jenkins-terraform'
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

pipeline {
  agent any 

  stages {
    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh 'terraform init'
        }

      }
    }
    
    stage('Terraform Plan') {
      steps {
        dir('terraform') {
          sh 'terraform plan -out=tfplan'
        }
      }
    }
  }
}

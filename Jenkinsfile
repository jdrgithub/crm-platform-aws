pipeline {
  agent any 

  stages {
    stage('Check AWS CLI') {
        steps {
            sh 'aws --version'
        }
    }

    stage('Verify AWS Access') {
        steps {
            sh 'aws sts get-caller-identity'
        }
    }

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

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }
}

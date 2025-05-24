pipeline {
  agent any

  stages {
    stage('Install Terraform if needed') {
      steps {
        sh '''
          if ! command -v terraform >/dev/null; then
            echo "Installing Terraform..."
            apt-get update && apt-get install -y wget unzip gnupg software-properties-common
            wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
            apt-get update && apt-get install terraform -y
          fi
          terraform version
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }
  }
}
pipeline {
    agent {
        dockerContainer {
            image 'hashicorp/terraform:light'
            args '-u root'  // Optional, if needed for apt installs
        }
    }

    stages {
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }
    }
}

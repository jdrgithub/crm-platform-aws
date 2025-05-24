pipeline {
    agent {
        docker {
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

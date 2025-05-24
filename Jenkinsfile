pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:light'
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

pipeline {
  agent any

  stages {

    stage('Export Requirements') {
      steps {
        sh '''
          mkdir -p build
          poetry export -f requirements.txt --without-hashes --output build/requirements.txt
        '''   
      }
    }

    stage('Build Lambda Package') {
      steps {
        sh '''
          rm -rf lambda_build
          mkdir -p lambda_build/handlers
          mkdir -p lambda_build/models
          mkdir -p lambda_build/services

          # Copy handler
          cp src/handlers/create_contact.py lambda_build/handlers/
          cp src/models/contact.py lambda_build/models/
          cp src/services/dynamodb_service.py lambda_build/services/

          # Install dependencies
          pip install -r build/requirements.txt -t lambda_build/

          # Create zip inside lambda_build
          cd lambda_build
          zip -r lambda_function.zip .

          # Move zip to Terraform dir so Terraform can find it
          mv lambda_function.zip ../terraform/lambda_function.zip
        '''
      }
    }

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

    stage('Terraform Deploy') {
      steps {
        sh 'terraform -chdir=terraform apply -auto-approve'
      }
    }

    stage('Set .env for Integration Tests') {
      steps {
        sh '''
          echo "API_GATEWAY_URL=$(terraform -chdir=terraform output -raw api_gateway_url)" > .env
        '''
      }
    }

    stage('Run Unit Tests') {
      steps {
        sh 'poetry run pytest tests/unit'
      }
    }

    stage('Run Integration Tests') {
      steps {
        sh 'poetry run pytest tests/integration'
      }
    }
  }
}

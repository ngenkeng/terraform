pipeline{
  agent any
  tools {
    terraform 'terraform'
  }
  stages{
      stage('Terraform Init'){
        steps{
            sh 'terraform init'
        }
      }
      stage('Terraform Plan'){
        steps{
          sh label: '', script: 'terraform plan'
        }
      }
  }
}
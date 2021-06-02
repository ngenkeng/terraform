pipeline{
  agent any
  tools {
    terraform 'terraform-11'
  }
  stages{
      stage('Terraform Init'){
        steps{
            sh label: '', script: 'terraform init'
        }
      }
      stage('Terraform Plan'){
        steps{
          sh label: '', script: 'terraform plan'
        }
      }
  }
}
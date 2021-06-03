/*
pipeline{
  agent any
  tools {
    terraform 'terraform'
  }
*/
pipeline {
    agent {
        any {
            image 'hashicorp/terraform:latest'
            label 'LINUX-SLAVE'
            args  '--entrypoint="" -u root -v /opt/jenkins/.aws:/root/.aws'
        }
    }
  stages{
      stage('Terraform Init'){
        steps{
        sh """
          PATH=/bin/terraform
          terraform init"
        }
      }
      stage('Terraform Plan'){
        steps{
          sh label: '', script: 'terraform plan'
        }
      }
  }
}
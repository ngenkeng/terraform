/*
pipeline{
  agent any
  tools {
    terraform 'terraform'
  }
*/
pipeline {
    agent {

      image: 'hashicorp/terraform:latest'
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
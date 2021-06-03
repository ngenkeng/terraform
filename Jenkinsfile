/*
pipeline{
  agent any
  tools {
    terraform 'terraform'
  }
*/

/*
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
*/

pipeline{
  agent {
        docker {image 'hashicorp/terraform:light'}
    }
  stages{
    stage('terraform init'){
      steps{
        sh "terraform init"
      }
    }
  }
}
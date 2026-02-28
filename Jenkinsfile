pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '3', artifactNumToKeepStr: '3'))
    }
    parameters {
        choice(
            name: 'action', 
            choices: ['opened', 'synchronize', 'reopened'], 
            description: 'PR Action'
        )
        string(
            name: 'pr_to_ref', 
            defaultValue: 'main', 
            description: 'Target branch (base ref)'
        )
        string(
            name: 'pr_from_ref', 
            defaultValue: 'dev', 
            description: 'Source branch (head ref)'
        )
        string(
            name: 'pr_id', 
            defaultValue: '1', 
            description: 'Pull Request ID'
        )
    }
    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'action', value: '$.action'],
                [key: 'pr_to_ref', value: '$.pull_request.base.ref'],
                [key: 'pr_from_ref', value: '$.pull_request.head.ref'],
                [key: 'pr_id', value: '$.pull_request.id']
            ],
            causeString: 'Triggered by PR #$pr_id to $pr_to_ref',
            // token: 'your-webhook-token',
            printContributedVariables: true,
            printPostContent: true,
            silentResponse: false,
            regexpFilterText: '$action$pr_to_ref',
            regexpFilterExpression: '(opened|reopened|synchronize)main'
        )
    }
    tools {
        nodejs 'nodejs20'
    }
    environment {
        SONAR_HOME = tool 'sonarqube-scanner' // POint out the sonar scanner plugin you added in the tool section
    }
    stages {
        stage('Git Checkout') {
            steps {
                script {
                    def branch = params.pr_from_ref ?: env.pr_from_ref
                    git branch: "${branch}", credentialsId: 'sydsulai-jenkinsgithub-int-pat', url: 'https://github.com/sydsulai/devsecops.git'
                }
            }
        }
        stage('FrontEnd Compilation') {
            steps {
                dir('client') {
                    sh 'find . -name "*.js" -exec node --check {} +'
                }
            }
        }
        stage('BackEnd Compilation') {
            steps {
                dir('api') {
                    sh 'find . -name "*.js" -exec node --check {} +'
                }
            }
        }
        stage('GitLeaks Scan') {
            steps {
                sh 'gitleaks detect --source ./client --exit-code 1' // --report-format=csv --report-path=/app/gitleaks_report.csv
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') { // POint out the Remote SonarQube server you added in the Configure System section
                    sh '$SONAR_HOME/bin/sonar-scanner -Dsonar.projectKey=devsecops -Dsonar.sources=.'
                }
            }
        }
        // stage('Quality Gate Check') {
        //     steps {
        //         timeout(time: 5, unit: 'Minutes') {
        //             waitForQualityGate abortPipeline: false, credentialsId: 'JENKINS-SONARQUBE-TOKEN'
        //         }
        //     }
        // }
        stage('Trivy Scan Client') {
            steps {
                sh 'trivy fs ./client --scanners=vuln,misconfig,secret,license --format table -o client-trivy-report.yaml '
            }
        }
        stage('Trivy Scan API') {
            steps {
                sh 'trivy fs ./api --scanners=vuln,misconfig,secret,license --format table -o api-trivy-report.yaml'
            }
        }
        stage('Build Image and Push API Image to ECR') {
            steps {
                script {
                    withDockerRegistry(url: '829007908826.dkr.ecr.ap-south-1.amazonaws.com/decsecops/api') {
                        dir('api') {
                            sh 'docker build -t devsecops-api:latest -f api/Dockerfile .'
                            sh 'docker tag devsecops-api:latest 829007908826.dkr.ecr.ap-south-1.amazonaws.com/decsecops/api:v1.0.0'
                            sh 'docker push 829007908826.dkr.ecr.ap-south-1.amazonaws.com/decsecops/api:v1.0.0'
                        }
                    }
                }
            }
        }
        stage('Build Image and Push Client Image to ECR') {
            steps {
                script {
                    withDockerRegistry(url: '829007908826.dkr.ecr.ap-south-1.amazonaws.com/decsecops/client') {
                        dir('client') {
                            sh 'docker build -t devsecops-client:latest -f client/Dockerfile .'
                            sh 'docker tag devsecops-client:latest 829007908826.dkr.ecr.ap-south-1.amazonaws.com/decsecops/client:v1.0.0'
                            sh 'docker push 829007908826.dkr.ecr.ap-south-1.amazonaws.com/decsecops/client:v1.0.0'
                        }
                    }
                }
            }
        }
    }
}
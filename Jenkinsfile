pipeline {
    agent any
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
        SONAR_HOME = tool 'sonarqube-scanner'
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: "${env.pr_from_ref}", credentialsId: 'sydsulai-jenkinsgithub-int-pat', url: 'https://github.com/sydsulai/devsecops.git'
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
                withSonarQubeEnv('sonarqube') {
                    sh '$SONAR_HOME/bin/sonar-scanner -Dsonar.projectKey=devsecops -Dsonar.sources=. -Dsonar.host.url=http://52.66.208.134:9000'
                }
            }
        }
        stage('Quality Gate Check') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    withQualityGate abortPipeline: true, credentialsId: 'sonarqube-token'
                }
            }
        }
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
    }
}
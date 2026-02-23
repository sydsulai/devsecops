pipeline {
    agent any
    tools {
        nodejs 'nodejs20'
    }
    environment {
        SONAR_HOME = tool 'sonarqube-scanner'
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/sydsulai/devsecops.git'
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
                    sh '$SONAR_HOME/bin/sonar-scanner -Dsonar.projectKey=devsecops -Dsonar.sources=. -Dsonar.host.url=http://localhost:9000'
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
        stage('Trivy Scan') {
            steps {
                sh 'trivy fs --format table -o fs-report.html .'
            }
        }
    }
}
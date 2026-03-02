# devsecops
E2E devsecops pipeline PROD level. This repo integrates app with security checks like SAST, DAST, Code Quality, Image Scanning, Secret Leaks etc.,

## Shift Left Security

## CI/CD Pipeline Steps and Description
1. Git Checkout
2. Compilation
3. GitLeaks - For Secrets Exposure Check
4. FileSystemCheck using Trivy - Any vulnerabilities in dependency modules
5. UnitTesting
6. Sonarqube Analysis(SAST) - Bugs, Vulnerability
7. Quality Gate Check
8. Build Docker Image
9. Scan Docker Image with Trivy
10. Push Image to DockerHub/AWS ECR

## Tools/Plugins Required

- NodeJs - Node JS plugin is required. Added it to tools to make it available.
- Pipeline Stage View - Plugin is required.
- SonarQube Scanner - Plugin is required.
- Generic Webhook Trigger - Build when PR is submitted to Main from any other branches.
- SonarQube Quality Gate - To create a webhook and wait for QualityGate status
- Docker Pipeline - To Build and Push image from Jenkins. 
- Docker Compose Setup (Optional)
- AWS ECR - Plugin to authorize the image push from Jenkins Pipeline

## ENV/Manual Installation/Credentials

- Sonarqube - Remote URL and Credentials
- gitLeaks - Manual Installation in Server
- trivy - Manual Installation in Server
- Docker - Install Docker
- AWS ECR IAM Role - Provided Instance Role to EC2 Instance in which Jenkins is running.

## Difference between plugin and installation:

- Plugin is downloaded and managed by Jenkins and is managed through Global Tools management. Environment setup is available throughout the job-execution which is using the plugin. Version Switching is possible through simple one liner in tools section.
- Global Installation through **apt-get** is managed by the linux-admin team. In case new version is needed it needs to be dowloaded and version switching needs to be done manually in the Jenkins Job.

## Jenkins Github Intagration

1. Advised to create through Github Oauth Client ID and Secret. I did it through Github PAT Token
1. Store PAT token as username and password in Jenkins Credentials.

## Ref Docs

- **Jenkins Installation** - [Jenkins](https://www.jenkins.io/doc/book/installing/)
- **SonarQube INstallation** - [SonarQube](https://docs.sonarsource.com/sonarqube-server/server-installation), [Medium](https://baraqheart.medium.com/install-sonarqube-on-ubuntu-machine-1c1eb4002ab6)
- **Trivy Installation** - [Trivy](https://trivy.dev/docs/latest/getting-started/installation/#debianubuntu-official)
- **Integrating Sonarqube with Jenkins** [Integration](https://medium.com/@lilnya79/integrating-sonarqube-with-jenkins-fe20e454ccf4)
- **Install Docker** - [Docker Installation](https://docs.docker.com/engine/install/ubuntu/)
- **Generic WebHook Plugin** - [Generic Webhook](https://github.com/jenkinsci/generic-webhook-trigger-plugin/blob/master/src/test/resources/org/jenkinsci/plugins/gwt/bdd/github/github-pull-request.feature)
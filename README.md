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

## Difference between plugin and installation:

-

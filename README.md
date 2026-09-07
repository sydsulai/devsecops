# Devsecops

E2E devsecops pipeline PROD level. This repo integrates app with security checks like SAST, DAST, Code Quality, Image Scanning, Secret Leaks etc.,

## Shift Left Security

### Git Security

1. .gitignore file
2. pre-commit hook to check for any secret leaks through gitleaks.

    ```sh
    pre-commit install
    pre-commit autoupdate # Incase if you have any updates in the .pre-commit-config.yaml
    ```

3. Gitleaks can find all the leaks in all the commits.

    ```sh
    gitleaks detect
    ```

4. Enable Branch Protection to disable push to main/release/feature branch.
Settings -> Branch -> Rulesets

    - Target Branch
    - Require review bedore merging
    - Require all the checks to be passed before merging

5. Enabling RBAC
6. Mandatory Reviews through CODEOWNERS file
7. Dependabot - Constantly checks all your go.mod, pom.xml against vulnerability database. If there is package that is vulnerable, it can create PR and update the version in your repository.

### IAC Security

#### Best Practices

- No hardcoding of credentials(.gitignore, gitleaks)

#### Insecure Configuration using Checkov

- Terraform misconfiguration / INsecure Terraform Configuration (What if the S3 bucket is public)

    ```sh
    checkov -d .
    ```

#### Hashicorp Vault

- Production deployment of resources happens through CI/CD
- How do you provide credentials to your CI/CD systems.

  - Create a service account
  - Create AWS Credentials for that service account and this will access the AWS
  - Providing secrets in GitHub Actions/GitHub Secrets is generally not considered compliant or secure for production workloads because secrets can be exposed through workflow logs, repository access, pull request exposure, and long-lived storage patterns. Instead, use short-lived credentials via IAM roles, OIDC federation, or a dedicated secret manager such as HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, or GCP Secret Manager.

  - For example, prefer IAM roles with OIDC for GitHub Actions or Jenkins to grant temporary, scoped access rather than storing static long-lived credentials in GitHub Secrets.

- Need a secret management solution(Hashicorp Vault) to create short lived credentials to access AWS and deploy resources.

**Workflows:**

- Github Actions (Uses OIDC and request Vault)
- VAULT is provided with AWS credentials.
- VAULT creates an IAM USER with AWS Credentials and Its short lived
- One time setup of OIDC

```sh
vault server -dev -dev-root-token-id="root" -dev-listen-address="0.0.0.0:8200"
export VAULT_ADDR='http://127.0.0.0:8200'
vault login root
vault secrets enable aws
vault write aws/config/root \
    access_key= \
    secret_key= \
    region='ap-south-1'
vault auth enable jwt
vault write auth/jwt/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com"

vault policy write terraform-policy - <<EOF
path "aws/creds/terraform-policy" {
    capabilities = ["read"]
}
EOF

vault write auth/jwt/role/gh-actions-role - <<EOF
{
    "role_type": "jwt",
    "bound_audiences": ["https://github.com/sydsulai"],
    "user_claim": "sub",
    "bound_claims_type": "glob",
    "bound_claims": {
        "sub": "repo:sydsulai/devsecops:*"
    },
    "token_policies": ["terraform-policy"],
    "token_ttl": "1h"
}
EOF
```

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

## Difference between plugin and installation

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

## FAQ

1. Is Gitleaks the only secret-scanning utility in the market?

   No. Gitleaks is one of the popular open-source tools for detecting secrets and credentials in code and git history, but it is not the only option. Other commonly used tools include TruffleHog, GitGuardian, AWS Secret Scanner, Spectral, and Detect-Secrets. The choice depends on your environment, integration needs, compliance requirements, and whether you want open-source or managed SaaS capabilities.

2. 

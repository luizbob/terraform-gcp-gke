# GKE GCP Infrastructure

This repository contains the necessary code to provision a fully automated infrastructure on Google Cloud Platform (GCP) using Terraform, including a Kubernetes (GKE) cluster, network infrastructure, API Gateway, and application deployments.

## Architecture Overview

The implemented solution consists of:

- **GKE Cluster**: Private Kubernetes cluster with appropriate node configurations
- **Dedicated VPC**: Custom network with subnets for the GKE cluster
- **Kong API Gateway**: For authentication and request validation
- **RabbitMQ**: Message broker installed via Helm with authenticated access
- **Sample API**: Example HTTP API deployed to demonstrate the environment

## Project Structure

```
└── projects
    └── test
        └── southamerica-east1
            ├── applications
            │   ├── backend.tf
            │   ├── chart/
            │   │   ├── Chart.yaml
            │   │   ├── templates/
            │   │   └── values.yaml
            │   ├── data.tf
            │   ├── main.tf
            │   ├── provider.tf
            │   ├── terraform.tfvars
            │   ├── terragrunt.hcl
            │   └── variables.tf
            ├── gke
            │   ├── backend.tf
            │   ├── data.tf
            │   ├── kong/
            │   │   └── values.yaml
            │   ├── main.tf
            │   ├── provider.tf
            │   ├── rabbitmq/
            │   │   └── values.yaml
            │   ├── terraform.tfvars
            │   ├── terragrunt.hcl
            │   └── variables.tf
            └── vpc
                ├── backend.tf
                ├── data.tf
                ├── main.tf
                ├── provider.tf
                ├── terraform.tfvars
                ├── terragrunt.hcl
                └── variables.tf
```

## Deployment Instructions

### Prerequisites

- Google Cloud SDK (gcloud) installed and configured
- Terraform (v1.0+) installed
- Terragrunt installed
- kubectl installed
- Helm installed

### Step 1: Setup authentication

```bash
# Configure gcloud credentials
gcloud auth login
gcloud config set project your-project-id
```

### Step 2: Deploy the VPC

```bash
cd projects/test/southamerica-east1/vpc
terragrunt plan
terragrunt apply
```

### Step 3: Deploy the GKE Cluster and Core Components

```bash
cd ../gke
terragrunt plan
terragrunt apply
```

This step will:
- Create the GKE cluster
- Install Kong API Gateway
- Install RabbitMQ via Helm

### Step 4: Deploy the Sample Application

```bash
cd ../applications
terragrunt plan
terragrunt apply
```

## Testing the Deployment

### Testing the API without Authentication

```bash
# Get the Kong Gateway IP
export KONG_IP=$(kubectl get svc -n kong kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test the API without JWT token (should fail if JWT is enabled)
curl -i http://$KONG_IP/api
```

### Testing the API with Authentication

```bash
# For JWT authentication, first create a token
# This is a simple example - in real scenarios, use a proper JWT generator
JWT_SECRET="your-jwt-secret"
JWT_KEY="your-jwt-key"

# Create a JWT token (requires jwt-cli or similar tool)
export JWT_TOKEN=$(jwt encode --secret $JWT_SECRET --payload '{"sub":"test","exp":'$(($(date +%s)+3600))'}')

# Test with JWT
curl -i -H "Authorization: Bearer $JWT_TOKEN" http://$KONG_IP/api
```

### Validating RabbitMQ

```bash
# Port forward to access RabbitMQ
kubectl port-forward svc/rabbitmq -n rabbitmq 15672:15672 5672:5672

# In another terminal, verify the connection
# Either use the provided script:
./scripts/validate-rabbitmq.sh

# Or use the management UI:
# Access http://localhost:15672 in your browser with:
# Username: admin
# Password: adminPassword (as configured in values.yaml)
```

## Architecture Decisions

### Private GKE Cluster

We've chosen a private GKE cluster for enhanced security. With this approach:

- Nodes don't have public IP addresses, reducing attack surface
- The control plane is only accessible through authorized networks or IAP tunneling
- External communication is controlled via NAT gateway
- Workloads remain protected from direct internet exposure

### Kong API Gateway

We selected Kong Gateway (OSS) for the following reasons:

1. **Mature ecosystem**: Kong is a battle-tested solution with a large community and extensive plugin system
2. **Performance**: Low overhead and high throughput capabilities
3. **Authentication flexibility**: Native support for JWT, Basic Auth, and other authentication methods
4. **Kubernetes integration**: Native support for Kubernetes ingress resources with extended capabilities
5. **Extensibility**: Easy to add custom plugins and extend functionality

### Terragrunt Organization

The infrastructure is organized using Terragrunt to:

1. **Maintain modularity**: Each component is separated but interconnected
2. **Enforce dependency order**: Infrastructure is created in the correct sequence
3. **Apply consistent configurations**: Common configurations are shared through inheritance
4. **Support multi-environment deployments**: Structure can be replicated for different environments

### Cost Control

Labels are applied consistently across all resources to enable:

- Cost allocation by environment and application
- Resource tracking

## Security Considerations

- The GKE cluster uses private nodes
- All communications between services are encrypted
- JWT authentication protects API endpoints
- RabbitMQ has authentication enabled
- IAP tunneling is used for secure administrative access

## Automation with Atlantis

This infrastructure is facilitated when using Atlantis to automate the pull requests for deploying the infrastructure. Atlantis enables GitOps workflows by automating Terraform plan and apply operations directly from pull requests.

### Setting up Atlantis with Terragrunt

1. Create an `atlantis.yaml` file in the root of your repository:

```yaml
version: 3
projects:
- name: vpc
  dir: projects/test/southamerica-east1/vpc
  workflow: terragrunt
  autoplan:
    when_modified: ["*.tf", "*.hcl", "**/*.tf", "**/*.hcl"]
    enabled: true
- name: gke
  dir: projects/test/southamerica-east1/gke
  workflow: terragrunt
  autoplan:
    when_modified: ["*.tf", "*.hcl", "**/*.tf", "**/*.hcl"]
    enabled: true
- name: applications
  dir: projects/test/southamerica-east1/applications
  workflow: terragrunt
  autoplan:
    when_modified: ["*.tf", "*.hcl", "**/*.tf", "**/*.hcl", "chart/**"]
    enabled: true

workflows:
  terragrunt:
    plan:
      steps:
      - run: terragrunt plan -out=$PLANFILE
    apply:
      steps:
      - run: terragrunt apply $PLANFILE
```

2. Configure your VCS provider (GitHub, GitLab, etc.) to send webhooks to Atlantis

3. Set up necessary permissions for Atlantis:
   - Create a Service Account with appropriate permissions
   - Configure Workload Identity if running Atlantis in Kubernetes
   - Store credentials securely using Secret Manager

4. Deploy Atlantis:
   - For Kubernetes deployment, use the official Helm chart
   - For standalone deployment, use Docker or binary installation

5. Configure PR workflows:
   - Developers submit infrastructure changes via PR
   - Atlantis automatically runs `terragrunt plan`
   - Team reviews changes and comments "atlantis apply" to deploy
   - Atlantis executes `terragrunt apply` and reports results

This workflow ensures that:
- All infrastructure changes go through code review
- Plans are automatically generated for easy review
- Apply operations are tracked and logged
- Changes follow proper approval process

## Future Enhancements

1. Add monitoring and alerting using Cloud Monitoring/Prometheus
2. Implement CI/CD pipeline for application deployments
3. Setup backup and disaster recovery for stateful components
4. Implement automated certificate management
5. Add network policies for pod-to-pod communications

## Handling Sensitive Information

For production environments, it's recommended to store sensitive information like credentials and API keys in Google Secret Manager instead of directly in Terraform files.

### Setting up Secret Manager

1. Create secrets in Google Secret Manager:
```bash
# Create secrets
gcloud secrets create jwt-key --replication-policy="automatic"
gcloud secrets create jwt-secret --replication-policy="automatic"
gcloud secrets create rabbitmq-password --replication-policy="automatic"

# Add versions with your sensitive values
echo -n "your-jwt-key" | gcloud secrets versions add jwt-key --data-file=-
echo -n "your-jwt-secret" | gcloud secrets versions add jwt-secret --data-file=-
echo -n "your-rabbitmq-password" | gcloud secrets versions add rabbitmq-password --data-file=-
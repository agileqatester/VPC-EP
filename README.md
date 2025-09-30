# VPC PrivateLink Infrastructure

## Overview

This Terraform project creates a production-ready AWS VPC PrivateLink setup demonstrating secure cross-VPC communication without internet routing. The infrastructure includes two VPCs connected via AWS PrivateLink, with environment-specific configurations for development and production workloads.

## Architecture

### Provider VPC (10.0.0.0/16)
- **EC2 Instances**: Runs Python HTTP server on port 8080
  - **Dev**: Single instance (t3.micro)
  - **Prod**: Auto Scaling Group with 2-4 instances (t3.2xlarge) across multiple AZs
- **Network Load Balancer**: Routes traffic to EC2 instances with health checks
- **VPC Endpoint Service**: Exposes NLB via PrivateLink
- **EIC Endpoint**: Secure SSH access to EC2 instances

### Consumer VPC (10.1.0.0/16)
- **EC2 Instance**: Client instance for testing connectivity
- **VPC Endpoint**: Connects to provider service via PrivateLink
- **Route53 Private Zone**: Provides friendly DNS (`api.provider.local`)
- **EIC Endpoint**: Secure SSH access to EC2

### Connection Flow
```
Consumer EC2 → Route53 (api.provider.local) → VPC Endpoint → PrivateLink → NLB → Provider EC2(s)
```

## Environment Configuration

The project supports environment-specific configurations optimized for different use cases:

### Development Environment
- **Instance**: t3.micro (cost-optimized)
- **Storage**: 30GB, 3000 IOPS
- **Deployment**: Single AZ, single instance
- **Cost**: Minimal for testing and development

### Production Environment
- **Instance**: t3.2xlarge (performance-optimized)
- **Storage**: 100GB, 10000 IOPS
- **Deployment**: Multi-AZ Auto Scaling Group (2-4 instances)
- **High Availability**: Automatic failover and recovery
- **Cross-AZ Considerations**: Accepts minimal data transfer fees for HA benefits

## Usage

### Prerequisites
- AWS CLI configured
- Terraform installed
- SSH key pair generated (`~/.ssh/ira.pem.pub`)

### Deployment Commands

**Deploy Development Environment:**
```bash
terraform init
terraform plan -var-file=environments/dev.tfvars -var-file=terraform.tfvars
terraform apply -var-file=environments/dev.tfvars -var-file=terraform.tfvars
```

**Deploy Production Environment:**
```bash
terraform init
terraform plan -var-file=environments/prod.tfvars -var-file=terraform.tfvars
terraform apply -var-file=environments/prod.tfvars -var-file=terraform.tfvars
```

**Destroy Infrastructure:**
```bash
terraform destroy -var-file=environments/dev.tfvars -var-file=terraform.tfvars
```

### Testing Connectivity

1. **Connect to Consumer EC2:**
   ```bash
   aws ec2-instance-connect ssh --instance-id <consumer-instance-id> --os-user ec2-user --connection-type eice
   ```

2. **Test PrivateLink Connection:**
   ```bash
   curl http://api.provider.local:8080
   # Expected output: <h1>Hello from EC2!</h1>
   ```

3. **Alternative test using VPC Endpoint DNS:**
   ```bash
   curl http://vpce-xxx.vpce-svc-xxx.us-east-1.vpce.amazonaws.com:8080
   ```

## Configuration Files

- `terraform.tfvars`: Base configuration (region, project name, networking)
- `environments/dev.tfvars`: Development environment settings
- `environments/prod.tfvars`: Production environment settings

## Key Features

- **Security**: No internet gateways, all communication via private networks
- **High Availability**: Production Auto Scaling Group across multiple AZs
- **Environment-Specific**: Dev (single instance) vs Prod (ASG with 2-4 instances)
- **Cross-AZ Optimization**: Same AZ deployment to minimize data transfer costs
- **Accessibility**: EIC endpoints for secure SSH access
- **DNS**: Friendly DNS names for service discovery
- **Monitoring**: CloudWatch integration for logging
- **Auto Recovery**: ASG automatically replaces failed instances in production

## Important Notes

⚠️ **Always use environment-specific var files** - The project includes validation to prevent accidental deployments with default values.

🔒 **Private Communication** - All traffic flows through AWS private networks, no internet routing required.

📊 **Cost Optimization** - Use dev environment for testing, prod for production workloads.

🏗️ **Production Architecture** - Prod environment deploys Auto Scaling Group with multi-AZ instances for high availability.

💰 **Cross-AZ Data Transfer** - Production accepts minimal cross-AZ fees (~$0.01/GB) for high availability benefits.

🔄 **Auto Recovery** - ASG automatically maintains desired capacity and replaces unhealthy instances.
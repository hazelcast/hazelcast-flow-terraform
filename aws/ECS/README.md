This terraform configures a full Flow deployment on AWS, using ECS / Fargate.

### Important!
This script will create a public-facing Flow instance. You should modify this script to manage the visibility.

It provisions the following:
 * A dedicated VPC for Flow, with two subnets across two AZ's
 * An ECS Fargate task running Flow
 * An RDS Instance, which Flow can connect to
 * Logs written out to CloudWatch
 * HTTPS over SSL:
   * A Route53 DNS entry
   * HTTPS certificate and loadbalancer instance with SSL termination from 443 to 9021
   

## Setup
Clone the repository:

```sh
git clone https://github.com/yourusername/flow-deployment-terraform.git
cd flow-deployment-terraform
```

Initialize Terraform:
```sh
terraform init
```

## Configuration

### Terraform Variables

The deployment can be customized using Terraform variables. These variables can be set in a terraform.tfvars file or passed directly via the command line.

Copy `locals.tfvars.examples` and configure with any variables you wish to tweak.

### AWS Credentials
Ensure that your AWS CLI is configured with the necessary credentials:

```sh
aws configure
```
Alternatively, you can set the AWS credentials as environment variables:

```sh
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
```
## Deployment
To deploy the Flow application to AWS ECS on Fargate, follow these steps:

Create a Terraform plan:

```sh
terraform plan -out plan.out --var-file="locals.tfvars"
```
Apply the Terraform plan:

```sh
terraform apply plan.out --var-file="locals.tfvars"
```

This will provision all the necessary resources, including ECS clusters, task definitions, and services, to run your Flow application on AWS ECS Fargate.
> Note: This module is in alpha state and is likely to contain bugs and updates may introduce breaking changes. It is not recommended for production use at this time.
# Terraform Amazon ECS on AutoScaling Group Module 
Authors: Praveen Kumar Jeyarajan (pjeyaraj@amazon.com), Viyoma Sachdeva (viyoms@amazon.com) and Neel Shah (shahneel@amazon.com)

This Terraform module deploys Amazon Elastic Container Service (Amazon ECS) backed by AutoScaling Group (ASG). It deploys a AutoScaling Group created from the Launch Template the user provides. It then deploys a Amazon ECS cluster backed by the ASG, created before, as capacity provider. Users can create the necessary resources for the Launch Template as needed like the VPC, subnets, security group, etc. The module uses the Launch Template ID to create the ASG for use by the Amazon ECS.

## Deployment steps
### Manage state remotely using Terraform Cloud
1. Install Terraform. For instructions and a video tutorial, see [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). 
2. Sign up and log into Terraform Cloud. (There is a free tier available.)
3. Configure Terraform Cloud API access. Run the following to generate a Terraform Cloud token from the command line interface:

```
terraform login
export TERRAFORM_CONFIG
export TERRAFORM_CONFIG="$HOME/.terraform.d/credentials.tfrc.json"
```

4. Configure the AWS Command Line Interface (AWS CLI). For more information, see [Configuring the AWS CLI](https://doc.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
5. If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 
6. Clone this **aws-ia/terraform-aws-ecs-cluster** repository using the following command:

```
git clone https://github.com/aws-ia/terraform-aws-ecs-cluster
```

6. Change directory to the root repository directory.

```
cd /terraform-aws-ecs-cluster/
```

7. Change to the workspace configuration directory to initialize and run the configuration

```
cd setup_workspace
terraform init
terraform apply
```

8. After configuring the backend, change to the deploy directory with following command:

```
cd ../deploy
```

9. Initialize the deploy directory by running following command:

```
terraform init
```

10. Setup the values for the variables and start a Terraform run using the configuration files in your deploy directory. Run the following command:

```
terraform apply
```
 or
```
terraform apply -var-file="$HOME/.aws/terraform.tfvars"
```

11. Follow the documentation [here](https://aws.amazon.com/getting-started/hands-on/deploy-docker-containers/) to deploy docker containers to Amazon ECS and scale them to the desired count as needed.

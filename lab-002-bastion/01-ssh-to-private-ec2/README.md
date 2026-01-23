# Bastion Host - AWS Lab

## What is a Bastion Host?

A **Bastion Host** (also called a **Jump Host** or **Jump Box**) is a specially configured server that acts as a secure intermediary for accessing other resources within a private network. It's a widely used security pattern in cloud architectures.

### Key Characteristics

- **Single Entry Point**: Concentrates access to internal resources through a single server
- **Security Layer**: Adds a layer of protection between external users and private resources
- **Controlled Access**: Allows auditing and controlling who accesses which resources
- **Simplifies Management**: Centralizes SSH key and permission management
- **Reduces Attack Surface**: Only the bastion is exposed to the internet

### Access Flow

![diagram](./docs/diagrama.drawio.svg)

## This Project: Bastion Host for Accessing a Private EC2 via SSH

This Terraform project creates a complete bastion host infrastructure on AWS with the following components:

### 📋 Created Components

#### 1. **Bastion EC2 Instance**
- **Type**: t2.micro (eligible for free tier)
- **AMI**: Amazon Linux 2023
- **Location**: Public Subnet
- **Public IP**: Not associated by default (can be configured with Elastic IP)
- **Purpose**: Serve as intermediary to access ElastiCache and other private resources

#### 2. **Security Group**
Network rules configured for:
- **Ingress**: SSH (port 22) from anywhere (0.0.0.0/0)
- **Egress**: All traffic allowed (allows connection to any internal resource)
- **Tags**: Applied for better tracking

#### 3. **IAM Role and Policy**
- **Role**: `lab-bastion-role` - Allows the instance to assume the role
- **Policy**: Defines specific permissions to access AWS resources (EC2, SSM, etc.)
- **Instance Profile**: Links the role to the EC2 instance

#### 4. **User Data Script**
The initialization script automatically installs:
- Python pip (package manager)
- Redis Client (to connect to ElastiCache)

### 🏗️ File Structure

```
bastion-host/
├── infra/                           # Terraform configurations
│   ├── main.tf                      # EC2 instances definition
│   ├── iams.tf                      # Role, Policy and Instance Profile
│   ├── sg.tf                        # Security Groups and Rules
│   ├── variables.tf                 # Configuration variables
│   ├── data.tf                      # Data sources (AMI, VPC, Subnet)
│   ├── locals.tf                    # Reusable local values
│   ├── output.tf                    # Terraform outputs
│   ├── provider.tf                  # AWS provider configuration
│   ├── terraform.tfstate            # Current infrastructure state
│   ├── terraform.tfstate.backup     # Previous state backup
│   ├── .terraform.lock.hcl          # Terraform dependency lock
│   ├── iam/
│      ├── policy/
│      │   └── policy-execution-bastion.json    # IAM Role permissions
│      └── trust/
│          └── trust-execution-bastion.json     # Trust relationship
│   
├── ssh-connect/                     # Scripts to connect to bastion
   ├── ssh-bastion-connect.sh       # Automatic SSH connection script
   └── lab-key-pair.pem             # Private key (do not version)

```

## 📁 Terraform Files Description

### infra/main.tf
Defines the two EC2 instances:

- **`bastion_public_instance`**: Public instance that functions as bastion host
  - Type: `t2.micro`
  - AMI: Amazon Linux 2023
  - Public IP: Automatically assigned
  - Location: Public Subnet
  - Purpose: Intermediary for accessing private resources

- **`private_instance`**: Private instance for demonstration/testing
  - Type: `t2.micro`
  - Location: Private Subnet
  - No public IP
  - Accessible only through the bastion

### infra/iams.tf
Manages IAM permissions:

- **IAM Role** (`lab-bastion-role`): Role assumed by the instance
- **IAM Policy**: Defines specific permissions for the role
- **Instance Profile**: Links the role to the EC2 instance

### infra/sg.tf
Defines Security Groups:

- **Bastion Security Group** (`lab-bastion-host-sg`)
  - Ingress: SSH (port 22) from anywhere (0.0.0.0/0)
  - Egress: All traffic allowed

- **Private Instance Security Group** (`lab-server-private-sg`)
  - Ingress: SSH only from bastion
  - Egress: Traffic as needed

### infra/data.tf
Dynamically fetches existing information:

- **AWS AMI**: Filters the latest Amazon Linux 2023 AMI
- **AWS VPC**: Locates the VPC by tag `Name: vpc-lab`
- **AWS Public Subnet**: Locates the public subnet by tag
- **AWS Private Subnet**: Locates the private subnet by tag

### infra/locals.tf
Defines reusable local values:

- `label = "lab-bastion"` - Prefix for resource names
- `namehostpublic = "bastion-host"` - Public instance name
- `namehostprivate = "server-private"` - Private instance name
- `tag_environment = "lab"` - Environment tag

### infra/variables.tf
Variáveis configuráveis:

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `region` | string | `sa-east-1` | Região AWS |
| `availability_zone` | string | `sa-east-1a` | Zona de disponibilidade |
| `ami_instance_type` | string | `t2.micro` | Tipo de instância |
| `name_key_pair` | string | `lab-key-pair` | Nome da key pair AWS |
| `vpc_selected_filter` | object | `tag:Name = vpc-lab` | Filtro para VPC |
| `public_subnet_selected_filter` | object | `tag:Name = public-subnet-1a` | Filtro para subnet pública |
| `ami_selected_filter` | object | `al2023-ami-2023*` | AMI Filter |

### infra/output.tf
Displays information after deployment:

- `vpc_aws`: ID of the VPC used
- `subnet_public`: ID of the public subnet
- `ami`: ID of the AMI used

### infra/provider.tf
AWS provider configuration and Terraform requirements

## 🔗 ssh-connect Folder

This folder contains tools for connecting to the bastion host:

### ssh-bastion-connect.sh
Automatic SSH connection script that:

1. **Validates the private key**: Searches for the `lab-key-pair.pem` file in the local directory
2. **Sets permissions**: Sets permissions 400 for the key (restrictive)
3. **Gets public IP**: Queries AWS CLI to get the bastion's public IP
4. **Connects via SSH**: Opens an SSH session with the `-A` flag (SSH Agent Forwarding)

**Usage:**
```bash
cd ssh-connect/
chmod +x ssh-bastion-connect.sh
./ssh-bastion-connect.sh
```

**Requirements:**
- AWS CLI configured with credentials
- `lab-key-pair.pem` file in the same folder
- Execution permission for the script

**What the script does:**
```bash
# 1. Validates key existence
# 2. Sets correct permissions
# 3. Gets bastion's public IP via AWS CLI
# 4. Establishes interactive SSH connection
# 5. Inside the bastion, you can connect to the private instance
```

### lab-key-pair.pem
- **Description**: Private key generated in AWS
- **Security**: Never version in git (add to `.gitignore`)
- **Obtaining**: Download via AWS Console when the key pair is created
- **Permissions**: Must have 400 (readable only by owner)

## 🚀 How to Use

### Prerequisites

1. **AWS CLI** configured with credentials
2. **Terraform** v1.0+
3. **Key Pair** created in AWS (specify the name in `variables.tf`)
4. **VPC and Subnet** already existing with tags configured
5. **SSH Client** installed (default on Linux/Mac, Git Bash on Windows)

### Deployment

```bash
# Access the infrastructure folder
cd infra/

# Initialize Terraform (downloads providers and modules)
terraform init

# Validate configuration (checks syntax)
terraform validate

# Plan deployment (shows what will be created)
terraform plan

# Apply configuration (creates resources in AWS)
terraform apply

# Get output information
terraform output
```

### Connecting to Bastion Host

#### Option 1: Using the Automatic Script (Recommended)

```bash
# Make sure you are in the ssh-connect folder
cd ssh-connect/

# Copy your private key to this folder
# cp /path/to/lab-key-pair.pem ./

# Run the connection script
chmod +x ssh-bastion-connect.sh
./ssh-bastion-connect.sh
```

The script automatically:
- ✅ Validates key existence
- ✅ Gets bastion's public IP via AWS CLI
- ✅ Connects with SSH and SSH Agent Forwarding

#### Option 2: Manual Connection

```bash
# Get bastion's public IP
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=bastion-host" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text

# Connect via SSH
ssh -i lab-key-pair.pem ec2-user@<BASTION_IP>

# Inside the bastion, connect to the private instance
ssh -i ~/.ssh/authorized_keys ec2-user@<PRIVATE_IP>
```

### Accessing Private Resources through Bastion

```bash
# Port Forwarding for ElastiCache
ssh -i lab-key-pair.pem \
    -L 6379:elasticache-endpoint:6379 \
    ec2-user@<BASTION_IP>

# On another terminal, connect to Redis locally
redis-cli -h localhost -p 6379

# Or for RDS
ssh -i lab-key-pair.pem \
    -L 3306:database.xyz.rds.amazonaws.com:3306 \
    ec2-user@<BASTION_IP>

# Connect to the database
mysql -h localhost -u admin -p
```

### Cleanup

```bash
# Remove all created resources
terraform destroy
```

## 🔒 Security

- **Restrictive Security Group**: Only SSH is allowed on ingress
- **IAM Role with Least Privilege**: Specific permissions defined
- **No Auto-Assign Public IP**: Public IP can be assigned via Elastic IP as needed
- **Audit**: All access can be logged via CloudTrail

## 📝 Use Cases

This bastion host is ideal for:

1. **ElastiCache Access (Redis/Memcached)** - Secure tunneling
2. **RDS Access** - Connect to private databases
3. **Private EC2 Management** - Indirect SSH
4. **Internal Deployments** - Run deployment scripts
5. **Network Troubleshooting** - Diagnose internal issues

## 🎯 Next Improvements

- [ ] Add Elastic IP for static IP
- [ ] Implement Auto Scaling Group with health checks
- [ ] Integrate with AWS Systems Manager Session Manager
- [ ] Add CloudWatch logs
- [ ] Configure alternative VPN
- [ ] Implement Bastions in multiple AZs

## 📚 References

- [AWS Bastion Host Best Practices](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/)
- [SSH Port Forwarding](https://linux.die.net/man/1/ssh)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

**Author**: AWS Labs  
**Date**: January 2026  
**Version**: 1.0  
**Versão**: 1.0

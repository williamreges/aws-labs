# Lab 006 - Lambda Java with Terraform and AWS CLI

This project demonstrates how to create, package, provision, and invoke an AWS Lambda function using Java 17, Terraform, and AWS CLI. The goal is to serve as a practical reference for those who want to explore Lambda with Java and infrastructure as code.

## 📁 Project Structure

```
├── app/
│   ├── validadigitocpffunction/   # Java Lambda function source code
│   │   ├── pom.xml
│   │   ├── src/main/java/org/example/
│   │   │   ├── GeneratorDigitoCpfHandler.java
│   │   │   ├── CalcularDACUtils.java
│   │   │   └── Pessoa.java
│   │   └── events/event-cpf.json # Example event for testing
│   └── generator-jar-to-infra.sh # Script to build and copy the JAR
├── infra/
│   ├── terraform/                # Infrastructure as code (Terraform)
│   │   ├── *.tf                  # Resource, variable, output, IAM, Lambda files
│   │   ├── iamr/                 # Policies and trust policies
│   │   └── code/                 # Where the JAR is copied
│   └── aws-cli-example/          # Alternative scripts for AWS CLI
├── invoke/-+-+-+-+-+
# Lab 006 - Lambda Java with Terraform and AWS CLI

This project demonstrates how to create, package, provision, and invoke an AWS Lambda function using Java 17, Terraform, and AWS CLI. The goal is to serve as a practical reference for those who want to explore Lambda with Java and infrastructure as code.
```

## 🚀 Overview

The main workflow consists of:
1. Develop the Lambda function in Java (folder `app/validadigitocpffunction`)
2. Package the JAR with Maven
3. Provision infrastructure with Terraform OR AWS CLI scripts
4. Invoke and test the Lambda function

---

## 📋 Prerequisites

- AWS account with permissions to create IAM, Lambda, S3
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/)
- [Java 17+](https://adoptium.net/)
- [Maven](https://maven.apache.org/)
- Configure AWS credentials (e.g., `aws configure` or profile file)

---

### ☕ Java Project Structure (`app/validadigitocpffunction`)

The Java application is a Maven-based Lambda function that validates and generates CPF check digits.

**Main Components:**

- **GeneratorDigitoCpfHandler.java**: Lambda handler entry point that processes incoming requests and returns the calculated CPF check digit.
- **CalcularDACUtils.java**: Utility class containing the business logic for calculating the DAC (check digit) using the CPF validation algorithm.
- **Pessoa.java**: Data model class representing a person with CPF information.
- **pom.xml**: Maven configuration file that manages dependencies (AWS Lambda Core, JSON processing libraries) and build settings, including compilation for Java 17.

**Build Process:**

The `generator-jar-to-infra.sh` script:
1. Compiles the Java source code with Maven
2. Packages it into a JAR file (`app.jar`)
3. Copies the JAR to `infra/terraform/code/` for Terraform to deploy

**Input/Output:**

The Lambda function accepts a JSON event with a CPF string (e.g., `{"cpf": "504647270"}`) and returns the CPF with its calculated check digits.

This packaged JAR is then deployed to AWS Lambda via Terraform, where it runs on Java 17 runtime.


## ☸️ Infrastructure (`infra/terraform`)

### provider.tf

```hcl
terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region  = var.region
    profile = var.profile
}
```

Resources:
- `terraform.required_version`: Specifies the minimum Terraform version required (>= 1.0).
- `terraform.required_providers.aws.source`: Defines the provider source (hashicorp/aws).
- `terraform.required_providers.aws.version`: Pins the AWS provider version (~> 5.0, allows 5.x updates).
- `provider "aws".region`: AWS region where resources will be created (uses `var.region` variable).
- `provider "aws".profile`: AWS CLI profile for authentication (uses `var.profile` variable).


### main.tf

```hcl
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  filename      = local.jar_fullpath
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_role.arn
  publish       = var.publish

  source_code_hash = filebase64sha256(local.jar_fullpath)

  tags = {
    label       = local.label
    environment = local.environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_alias" "alias_dev" {
  name             = "dev"
  description      = "Development environment - always points to latest"
  function_name    = aws_lambda_function.this.function_name
  function_version = "$LATEST"
}
```

Resources:

- `aws_lambda_function.this`: Creates the Lambda function with the following configuration:
- `function_name`: Name of the Lambda function (from `var.function_name`).
- `filename`: Path to the JAR file to be deployed (uses `local.jar_fullpath`).
- `handler`: Entry point for the Lambda invocation (e.g., `org.example.GeneratorDigitoCpfHandler::handleRequest`).
- `runtime`: Execution runtime, set to Java 17 (from `var.runtime`).
- `role`: IAM execution role ARN that grants permissions to the Lambda function.
- `publish`: When `true`, publishes a new version of the function after updates; when `false`, updates the `$LATEST` version.
- `source_code_hash`: Uses `filebase64sha256()` to generate a hash of the JAR file; when the hash changes, Terraform detects the change and redeploys the function.
- `tags`: Metadata tags for organization and tracking (label and environment).
- `lifecycle.create_before_destroy`: Ensures the new function version is created before the old one is destroyed, preventing downtime during updates.
- `aws_lambda_alias.alias_dev`: Creates an alias named "dev" that points to the `$LATEST` version, allowing stable references to the function without hardcoding version numbers. This is useful for development environments where the function is frequently updated.


### variables.tf

```hcl
variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "aulaaws"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "validadigitocpffunction"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "org.example.GeneratorDigitoCpfHandler::handleRequest"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "java17"
}

variable "jar_path" {
  description = "Relative path to the built jar file from the terraform folder"
  type        = string
  default     = "code/app.jar"
}

variable "publish" {
  description = "Whether to publish a new Lambda version when updating code"
  type        = bool
  default     = false
}
```


### locals.tf

```hcl
locals {
  jar_fullpath = abspath("${path.module}/${var.jar_path}")
  label        = "lab-lambda-java"
  environment  = "lab"
}
```
Resource: `locals`
- Defines reusable values, such as name prefixes, tags, and identifiers.


### iam.tf

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "aws-lambda-${var.function_name}-custom-role"
  assume_role_policy = templatefile("${path.module}/iamr/trust/policy-trust.json", {})
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.function_name}-inline-policy"
  role = aws_iam_role.lambda_role.id
  policy = templatefile("${path.module}/iamr/policy/policy.json", {
    region        = var.region
    account_id    = data.aws_caller_identity.current.account_id
    function_name = var.function_name
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```
Resources:
- `aws_iam_role.lambda_role`: Lambda execution role, assumes the Lambda service, uses trust policy.
- `aws_iam_role_policy.lambda_role_policy`: Inline policy for Lambda permissions.
- `aws_iam_role_policy_attachment.basic_execution`: Attaches the AWS managed policy for CloudWatch logs.

### outputs.tf

```hcl
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "lambda_role_arn" {
  description = "IAM role ARN attached to the Lambda"
  value       = aws_iam_role.lambda_role.arn
}
```
Resources:
- `output "lambda_function_arn"`: ARN of the created Lambda function.
- `output "lambda_function_name"`: Name of the Lambda function.
- `output "lambda_role_arn"`: ARN of the execution role.


### data.tf

```hcl
data "aws_caller_identity" "current" {}
```
Resources:
- `data.aws_caller_identity`: Gets the AWS account ID.

### iamr/trust/trust-policy.json
JSON trust policy file authorizing the Lambda service (`lambda.amazonaws.com`) to assume the execution role.

---

## 🛠️ Build and Deploy the Lambda Function

### 1. Generate the JAR file

```bash
cd app
./generator-jar-to-infra.sh
# The JAR will be copied to infra/terraform/code/app.jar
```

### 2. Provision Infrastructure with Terraform

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply -var="jar_path=code/app.jar"
```

Main variables in `variables.tf`:
- `regiao` (default: sa-east-1)
- `lambda_function_name` (e.g., validadigitocpffunction)
- `runtime` (e.g., java17)
- `handler` (e.g., org.example.GeneratorDigitoCpfHandler::handleRequest)
- `jar_path` (e.g., code/app.jar)

### 3. Invoking the Lambda manually

#### Via Bash scripts (invoke/)

```bash
# Synchronous invocation
cd invoke
./invoke_lambda_sync.sh

# Asynchronous invocation
./invoke_lambda_async.sh
```

#### Via AWS Console
- Go to Lambda → Functions → validadigitocpffunction
- Click "Test" and use the example payload:

```json
{
    "cpf": "504647270"
}
```

---

## 🧪 Tests and Example Event

The file `app/validadigitocpffunction/events/event-cpf.json` provides an example event for local tests or via AWS Console.

---

## ⚙️ Infrastructure Components (Terraform)

- IAM roles and policies for Lambda execution
- Lambda function (deployment via Maven-generated package)
- Auxiliary resources declared as data sources and outputs

Main files:
- `provider.tf`, `main.tf`, `variables.tf`, `locals.tf`, `outputs.tf`, `data.tf`, `iam.tf`, `lambda.tf`
- Policies in `iamr/policy/` and `iamr/trust/`

---

## 📤 Outputs

After `terraform apply`, useful outputs:
- `lambda_function_arn` - ARN of the created Lambda function
- `lambda_alias` - alias created (if applicable)
- `iam_role_arn` - ARN of the role used by Lambda

---

## 📝 References and Useful Links

- [Java - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-java.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Java 17 Lambda Example](https://github.com/awsdocs/aws-lambda-developer-guide/tree/main/sample-apps/java17-examples)
- [AWS CLI Lambda Docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/index.html)

---

# Lab 006 - Lambda Java com Terraform e AWS CLI

Este projeto demonstra como criar, empacotar, provisionar e invocar uma função AWS Lambda utilizando Java 17, Terraform e AWS CLI. O objetivo é servir como referência prática para quem deseja explorar Lambda com Java e infraestrutura como código.

## 📁 Estrutura do Projeto

```
├── app/
│   ├── validadigitocpffunction/   # Código-fonte Java da função Lambda
│   │   ├── pom.xml
│   │   ├── src/main/java/org/example/
│   │   │   ├── GeneratorDigitoCpfHandler.java
│   │   │   ├── CalcularDACUtils.java
│   │   │   └── Pessoa.java
│   │   └── events/event-cpf.json # Exemplo de evento para teste
│   └── generator-jar-to-infra.sh # Script para build e cópia do JAR
├── infra/
│   ├── terraform/                # Infraestrutura como código (Terraform)
│   │   ├── *.tf                  # Arquivos de recursos, variáveis, outputs, IAM, Lambda
│   │   ├── iamr/                 # Políticas e trust policies
│   │   └── code/                 # Local onde o JAR é copiado
│   └── aws-cli-example/          # Scripts alternativos para AWS CLI
├── invoke/                       # Scripts para invocação manual da Lambda
│   ├── invoke_lambda_sync.sh
│   └── invoke_lambda_async.sh
```

## 🚀 Visão Geral

O fluxo principal consiste em:
1. Desenvolver a função Lambda em Java (pasta `app/validadigitocpffunction`)
2. Empacotar o JAR com Maven
3. Provisionar a infraestrutura com Terraform OU scripts AWS CLI
4. Invocar e testar a função Lambda

---

## 📋 Pré-requisitos

- Conta AWS com permissões para criar IAM, Lambda, S3
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/)
- [Java 17+](https://adoptium.net/)
- [Maven](https://maven.apache.org/)
- Configurar credenciais AWS (ex: `aws configure` ou arquivo de profile)

---


## 🔧 Infraestrutura (`infra/terraform`)

### provider.tf
Resource: `provider "aws"`
- Configura o provedor AWS, define a região (`region`), autenticação e permite interação com os serviços AWS.

### main.tf
Resources:
- `aws_lambda_function.validadigitocpffunction`: Cria a função Lambda, define nome, handler, runtime, timeout, memória, role, caminho do JAR.
- `source_code_hash`: Usa `filebase64sha256()` para detectar mudanças no JAR e atualizar a função.
- (Pode incluir associações entre recursos, como permissões ou triggers.)

### variables.tf
Declaração das variáveis principais:
| Variável | Tipo | Default | Descrição |
|----------|------|---------|-------------|
| `regiao` | string | `sa-east-1` | Região AWS |
| `lambda_function_name` | string | `validadigitocpffunction` | Nome da função Lambda |
| `runtime` | string | `java17` | Runtime da Lambda |
| `handler` | string | `org.example.GeneratorDigitoCpfHandler::handleRequest` | Handler Java |
| `jar_path` | string | `code/app.jar` | Caminho do JAR compilado |
| `timeout` | number | `30` | Timeout da Lambda (segundos) |
| `memory_size` | number | `512` | Memória da Lambda (MB) |
| `tag_environment` | string | `lab-006` | Tag de ambiente |

### locals.tf
Resource: `locals`
- Define valores reutilizados, como prefixos de nomes, tags, identificadores.

### iam.tf
Resources:
- `aws_iam_role.lambda_execution_role`: Role de execução da Lambda, assume o serviço Lambda (`lambda.amazonaws.com`), usa trust policy (`iamr/trust/trust-policy.json`).
- `aws_iam_role_policy_attachment.lambda_basic_execution`: Anexa a policy gerenciada `AWSLambdaBasicExecutionRole` para logs no CloudWatch.
- (Pode incluir policies inline, permissões customizadas, associações com outras policies.)

### lambda.tf
Resources:
- Detalhes da configuração da função Lambda (variáveis de ambiente, VPC, layers, permissões de invocação, triggers).

### outputs.tf
Resources:
- `output "lambda_function_arn"`: ARN da função Lambda criada.
- `output "lambda_function_name"`: Nome da função Lambda.
- `output "iam_role_arn"`: ARN da role de execução.
- (Outros outputs podem ser definidos conforme necessidade.)

### data.tf
Resources:
- `data.aws_caller_identity`: Obtém o ID da conta AWS.
- `data.aws_region`: Obtém a região atual.
- Usado para compor nomes dinâmicos, ARNs, condicionar recursos.

### iamr/trust/trust-policy.json
Arquivo JSON de trust policy autorizando o serviço Lambda (`lambda.amazonaws.com`) a assumir a role de execução.


## 🛠️ Build e Deploy da Função Lambda

### 1. Gerar o JAR da função

```bash
cd app
./generator-jar-to-infra.sh
# O JAR será copiado para infra/terraform/code/app.jar
```

### 2. Provisionar Infraestrutura com Terraform

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply -var="jar_path=code/app.jar"
```

Principais variáveis em `variables.tf`:
- `regiao` (default: sa-east-1)
- `lambda_function_name` (ex: validadigitocpffunction)
- `runtime` (ex: java17)
- `handler` (ex: org.example.GeneratorDigitoCpfHandler::handleRequest)
- `jar_path` (ex: code/app.jar)

### 3. Invocando a Lambda manualmente

#### Via scripts Bash (invoke/)

```bash
# Invocação síncrona
cd invoke
./invoke_lambda_sync.sh

# Invocação assíncrona
./invoke_lambda_async.sh
```

#### Via Console AWS
- Acesse Lambda → Funções → validadigitocpffunction
- Clique em "Testar" e use o payload de exemplo:

```json
{
	"cpf": "504647270"
}
```

---

## 🧪 Testes e Exemplo de Evento

O arquivo `app/validadigitocpffunction/events/event-cpf.json` traz um exemplo de evento para testes locais ou via Console AWS.

---

## ⚙️ Componentes da Infraestrutura (Terraform)

- IAM roles e policies para execução da Lambda
- Função Lambda (deploy via pacote gerado pelo Maven)
- Recursos auxiliares declarados como data sources e outputs

Arquivos principais:
- `provider.tf`, `main.tf`, `variables.tf`, `locals.tf`, `outputs.tf`, `data.tf`, `iam.tf`, `lambda.tf`
- Políticas em `iamr/policy/` e `iamr/trust/`

---

## 📤 Outputs

Após o `terraform apply`, outputs úteis:
- `lambda_function_arn` - ARN da função Lambda criada
- `lambda_alias` - alias criado (se aplicável)
- `iam_role_arn` - ARN da role usada pela Lambda

---

## 📝 Referências e Links Úteis

- [Java - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-java.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Exemplo Java 17 Lambda](https://github.com/awsdocs/aws-lambda-developer-guide/tree/main/sample-apps/java17-examples)
- [AWS CLI Lambda Docs](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/index.html)

---

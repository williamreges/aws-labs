# Provendo Recursos ECS - ALB com AWS CLI

Exemplos em shellscripts que utilizam **AWS CLI** para criar recursos como **ECS**, **ECR** e **ALB**

## 🚀 Começando

Existem outras maneiras até melhores de se prover recursos na AWS através de linha de comando com por exemplo o
`Terraform`, porém esse repo é destinado para quem tem curiosidade de com prover recursos utilizando a `AWS CLI` em seu
pc ou até mesmo tendo uma ideia de como prover uma esteira de CI/CD baseado em AWS CLI.

## 🛠 Skills

AWS, AWS CLI, Bash, ShellScript, Docker

## Features

- Reduz o tempo de desenvolvimento
- Pode ser utilizado como CI/CD

## Instalação

Primeiramente é necessário ter uma conta AWS e ter instalado localmente o AWS Cli. No meu exemplo como utilizo Linux
Ubuntu rodo o seguinte comando

```bash
  sudo snap install aws-cli
```

Após instalar o CLI confiugue um profile para a conta que estiver logado. No exemplo desse repositório os arquivos shell
tem uma variável `PROFILE=aulaaws` que faz com que os comandos AWS CLI execute comandos dentro da AWS através de
profile. No entando configure conforme abaixo:

```bash
  aws configure --profile aulaaws
```

Com esse comando informe o `Access Key ID`, `Secret Access Key `, `Region Name` e `Output Format` conforme exemplo
abaixo:

```bash
AWS Access Key ID [None]: xxxxx
AWS Secret Access Key [None]: xxxx
Default region name [None]: sa-east-1
Default output format [None]: json

```

## Crie os Recursos com Script

Vamos começar executando alguns scrips na ordem que está definido seus nomes dentro da pasta raiz `ecs-alb-cli-example`.

O script [01_create_cluster.sh](01_create_cluster.sh) criará um cluster com nome `app-cluster`:

```bash
  bash 01_create_cluster.sh
```

O script [02_create_alb.sh](02_create_alb.sh) ira criar um Application Load Balancer como `lb-app`:

```bash
  bash 02_create_alb.sh
```

Aguarde o script anterior finalizar e rode o script [03_create_tg.sh](03_create_tg.sh) irá criar um Target Group padrão
para o Load Balancer com o nome `tg-app`:

```bash
  bash 03_create_tg.sh
```

O script [04_create_listener.sh](04_create_listener.sh) irá criar um Listener para que o Load Balancer possa integrar
com o Target Group:

```bash
  bash 04_create_listener.sh
```

## Deployment

Para fazer um deploy de um app dentro do ECS com AWS CLI é necessário alguns passos como criar um repositório no `ECR`,
criar um `TaskDefinition` desse repositório para definir uma `Task` e depois criar um `Service` onde fará o
gerenciamento de replicas de `Task` dentro do cluster `ECS`.

Nessa etapa temos duas pastas de exemplos de applicações, [app1](./app1) e [app2](./app2). Ambas tem um arquivo html que
irá ser construida em uma imagem docker `nginx` através de um dockerfile e a imagem será postado para um repositório no
`ECR`por AWS CLI. Como exemplo vamos ver o app1:

#### ECR - Repositório da Imagem

O script [01_ecr_gerar_image_nginx.sh](./app1/01_ecr_gerar_image_nginx.sh) irá logar no serviço ECR com o docker (
Necessário Docker instalado), irá gerar imagem local com dockerfile customizado com o
arquivo [service1.html](./app1/service1.html) e irá fazer push dessa imagem para o repositório criado no ECR:

```bash
  cd ./app1
  bash ./app1/01_ecr_gerar_image_nginx.sh
```

#### TaskDefinition - Definir configuração do container

O script [02_taskdefinition_gerar_task.sh](./app1/02_taskdefinition_gerar_task.sh) irá configurar uma TaskDefinition
para a o container que irá rodar no service do ECS como task. Configurações com portas, variaveis de ambiente,roles e
dentre outros são definios no arquivo [fargate-task.json](./app1/fargate-task.json) que é lido pelo script e execultado
com AWS CLI conforme execução abaixo:

```bash
  cd ./app1
  bash 02_taskdefinition_gerar_task.sh
```

#### Service - Definir uma Task rodando em um Service

O script [03_ecs_generate_service.sh](./app1/03_ecs_generate_service.sh) irá configurar uma TaskDefinition para a o
container que irá rodar no service do ECS como task. Configurações com portas, variaveis de ambiente,roles e dentre
outros são definios no arquivo [fargate-task.json](./app1/fargate-task.json) que é lido pelo script e execultado com AWS
CLI conforme execução abaixo:

```bash
  cd ./app1
  bash 03_ecs_generate_service.sh
```


## Feedback

Se você tem algum feedback, por favor envie mensagem no linkedin abaixo:

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/william-reges-lima/)


## Referencias

* ECS
  * [O que é o Amazon Elastic Container Service](https://docs.aws.amazon.com/pt_br/AmazonECS/latest/developerguide/Welcome.html)
  * [ECS - Exemplos da Amazon usando AWS CLI](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli_ecs_code_examples.html)
  * [Criar uma tarefa do Linux no Amazon ECS para o tipo de inicialização do Fargate com a AWS CLI](https://docs.aws.amazon.com/pt_br/AmazonECS/latest/developerguide/ECS_AWSCLI_Fargate.html)
  * [ECS - AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/index.html)

* ECR
  * [ECR Exemplos da Amazon usando AWS CLI](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli_ecr_code_examples.html)
  * [ECR AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecr/index.html)

* ELB
  * [O que é Elastic Load Balancing](https://docs.aws.amazon.com/pt_br/elasticloadbalancing/latest/userguide/what-is-load-balancing.html)
  * [O que é um Network Load Balancer](https://docs.aws.amazon.com/pt_br/elasticloadbalancing/latest/network/introduction.html)
  * [ELB AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/index.html)
  * 

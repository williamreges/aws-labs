# Bastion Host - AWS Lab

## O que é um Bastion Host?

Um **Bastion Host** (também chamado de **Jump Host** ou **Jump Box**) é um servidor especialmente configurado que atua como intermediário seguro para acessar outros recursos dentro de uma rede privada. É um padrão de segurança amplamente utilizado em arquiteturas de nuvem.

### Características Principais

- **Ponto de Entrada Único**: Concentra o acesso a recursos internos através de um único servidor
- **Camada de Segurança**: Adiciona uma camada de proteção entre o usuário externo e os recursos privados
- **Acesso Controlado**: Permite auditar e controlar quem acessa quais recursos
- **Simplifica Gerenciamento**: Centraliza o gerenciamento de chaves SSH e permissões
- **Reduz Superfície de Ataque**: Apenas o bastion é exposto à internet

### Fluxo de Acesso

![desenho](./docs/diagrama.drawio.svg)


## Este Projeto: Bastion Host para Acesso ao ElastiCache

Este projeto Terraform cria uma infraestrutura completa de bastion host em AWS com os seguintes componentes:

### 📋 Componentes Criados

#### 1. **Instância EC2 Bastion**
- **Tipo**: t2.micro (elegível para camada gratuita)
- **AMI**: Amazon Linux 2023
- **Localização**: Subnet pública
- **IP Público**: Não associado por padrão (pode ser configurado com Elastic IP)
- **Propósito**: Servir como intermediário para acessar ElastiCache e outros recursos privados

#### 2. **Security Group**
Regras de rede configuradas para:
- **Ingresso**: SSH (porta 22) de qualquer lugar (0.0.0.0/0)
- **Egresso**: Todo tráfego liberado (permite conexão a qualquer recurso interno)
- **Tags**: Aplicadas para melhor rastreamento

#### 3. **IAM Role e Policy**
- **Role**: `lab-bastion-role` - Permite que a instância assuma a role
- **Policy**: Define permissões específicas para acessar recursos AWS (ElastiCache, etc.)
- **Instance Profile**: Vincula a role à instância EC2

#### 4. **User Data Script**
O script de inicialização instala automaticamente:
- Python pip (gerenciador de pacotes)
- Cliente Redis (para conectar ao ElastiCache)

### 🏗️ Estrutura de Arquivos

```
bastion-host/
├── infra/                           # Configurações Terraform
│   ├── main.tf                      # Definição das instâncias EC2
│   ├── iams.tf                      # Role, Policy e Instance Profile
│   ├── sg.tf                        # Security Groups e Rules
│   ├── variables.tf                 # Variáveis de configuração
│   ├── data.tf                      # Data sources (AMI, VPC, Subnet)
│   ├── locals.tf                    # Valores locais reutilizáveis
│   ├── output.tf                    # Outputs do Terraform
│   ├── provider.tf                  # Configuração do provider AWS
│   ├── terraform.tfstate            # Estado atual da infraestrutura
│   ├── terraform.tfstate.backup     # Backup do estado anterior
│   ├── .terraform.lock.hcl          # Lock de dependências Terraform
│   ├── iam/
│      ├── policy/
│      │   └── policy-execution-bastion.json    # Permissões da IAM Role
│      └── trust/
│          └── trust-execution-bastion.json     # Trust relationship
│   
├── ssh-connect/                     # Scripts para conectar ao bastion
   ├── ssh-bastion-connect.sh       # Script automático de conexão SSH
   └── lab-key-pair.pem             # Chave privada (não versionar)

```

## 📁 Descrição dos Arquivos Terraform

### infra/main.tf
Define as duas instâncias EC2:

- **`bastion_public_instance`**: Instância pública que funciona como bastion host
  - Tipo: `t2.micro`
  - AMI: Amazon Linux 2023
  - IP Público: Atribuído automaticamente
  - Localização: Subnet pública
  - Propósito: Intermediária para acesso a recursos privados

- **`private_instance`**: Instância privada para demonstração/teste
  - Tipo: `t2.micro`
  - Localização: Subnet privada
  - Sem IP público
  - Acessível apenas através do bastion

### infra/iams.tf
Gerencia as permissões IAM:

- **IAM Role** (`lab-bastion-role`): Role assumida pela instância
- **IAM Policy**: Define as permissões específicas da role
- **Instance Profile**: Vincula a role à instância EC2

### infra/sg.tf
Define os Security Groups:

- **Bastion Security Group** (`lab-bastion-host-sg`)
  - Ingresso: SSH (porta 22) de qualquer lugar (0.0.0.0/0)
  - Egresso: Todo tráfego liberado

- **Private Instance Security Group** (`lab-server-private-sg`)
  - Ingresso: SSH apenas do bastion
  - Egresso: Tráfego conforme necessário

### infra/data.tf
Busca dinamicamente informações existentes:

- **AWS AMI**: Filtra a AMI mais recente do Amazon Linux 2023
- **AWS VPC**: Localiza a VPC pela tag `Name: vpc-lab`
- **AWS Subnet Pública**: Localiza a subnet pública pela tag
- **AWS Subnet Privada**: Localiza a subnet privada pela tag

### infra/locals.tf
Define valores locais reutilizáveis:

- `label = "lab-bastion"` - Prefixo para nomes de recursos
- `namehostpublic = "bastion-host"` - Nome da instância pública
- `namehostprivate = "server-private"` - Nome da instância privada
- `tag_environment = "lab"` - Tag de ambiente

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
| `ami_selected_filter` | object | `al2023-ami-2023*` | Filtro para AMI |

### infra/output.tf
Exibe informações após o deployment:

- `vpc_aws`: ID da VPC utilizada
- `subnet_public`: ID da subnet pública
- `ami`: ID da AMI utilizada

### infra/provider.tf
Configuração do provider AWS e requisitos de Terraform

## 🔗 Pasta ssh-connect

Esta pasta contém ferramentas para conectar ao bastion host:

### ssh-bastion-connect.sh
Script automático de conexão SSH que:

1. **Verifica a chave privada**: Busca o arquivo `lab-key-pair.pem` no diretório local
2. **Configura permissões**: Define permissões 400 para a chave (restritivo)
3. **Obtém IP público**: Consulta AWS CLI para obter o IP público do bastion
4. **Conecta via SSH**: Abre uma sessão SSH com a flag `-A` (SSH Agent Forwarding)

**Uso:**
```bash
cd ssh-connect/
chmod +x ssh-bastion-connect.sh
./ssh-bastion-connect.sh
```

**Requisitos:**
- AWS CLI configurada com credenciais
- Arquivo `lab-key-pair.pem` na mesma pasta
- Permissão de execução do script

**O que o script faz:**
```bash
# 1. Valida existência da chave
# 2. Define permissões corretas
# 3. Busca o IP público do bastion via AWS CLI
# 4. Estabelece conexão SSH interativa
# 5. Dentro do bastion, você pode conectar à instância privada
```

### lab-key-pair.pem
- **Descrição**: Chave privada gerada na AWS
- **Segurança**: Nunca versionar em git (adicionar ao `.gitignore`)
- **Obtenção**: Download via AWS Console quando a key pair é criada
- **Permissões**: Deve ter 400 (readable apenas pelo proprietário)

## 🚀 Como Usar

### Pré-requisitos

1. **AWS CLI** configurada com credenciais
2. **Terraform** v1.0+
3. **Key Pair** criada na AWS (especificar o nome em `variables.tf`)
4. **VPC e Subnet** já existentes com as tags configuradas
5. **SSH Client** instalado (padrão em Linux/Mac, Git Bash no Windows)

### Deployment

```bash
# Acessar a pasta de infraestrutura
cd infra/

# Inicializar Terraform (baixa providers e módulos)
terraform init

# Validar configuração (verifica sintaxe)
terraform validate

# Planejar deployment (mostra o que será criado)
terraform plan

# Aplicar configuração (cria recursos na AWS)
terraform apply

# Obter informações de output
terraform output
```

### Conectando ao Bastion Host

#### Opção 1: Usando o Script Automático (Recomendado)

```bash
# Certifique-se de estar na pasta ssh-connect
cd ssh-connect/

# Copie sua chave privada para esta pasta
# cp /caminho/para/lab-key-pair.pem ./

# Execute o script de conexão
chmod +x ssh-bastion-connect.sh
./ssh-bastion-connect.sh
```

O script automaticamente:
- ✅ Valida a existência da chave
- ✅ Obtém o IP público do bastion via AWS CLI
- ✅ Conecta com SSH e SSH Agent Forwarding

#### Opção 2: Conexão Manual

```bash
# Obter o IP público do bastion
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=bastion-host" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text

# Conectar via SSH
ssh -i lab-key-pair.pem ec2-user@<BASTION_IP>

# Dentro do bastion, conectar à instância privada
ssh -i ~/.ssh/authorized_keys ec2-user@<IP_PRIVADO_DA_INSTANCIA>
```

### Acessando Recursos Privados através do Bastion

```bash
# Port Forwarding para ElastiCache
ssh -i lab-key-pair.pem \
    -L 6379:elasticache-endpoint:6379 \
    ec2-user@<BASTION_IP>

# Em outro terminal, conectar ao Redis localmente
redis-cli -h localhost -p 6379

# Ou para RDS
ssh -i lab-key-pair.pem \
    -L 3306:database.xyz.rds.amazonaws.com:3306 \
    ec2-user@<BASTION_IP>

# Conectar ao banco de dados
mysql -h localhost -u admin -p
```

### Limpeza

```bash
# Remover todos os recursos criados
terraform destroy
```

## 🔒 Segurança

- **Security Group Restritivo**: Apenas SSH é permitido no ingresso
- **IAM Role com Princípio do Menor Privilégio**: Permissões específicas definidas
- **No Auto-Assign Public IP**: IP público pode ser atribuído via Elastic IP conforme necessário
- **Auditoria**: Todos os acessos podem ser registrados via CloudTrail

## 📝 Casos de Uso

Este bastion host é ideal para:

1. **Acesso ao ElastiCache (Redis/Memcached)** - Tunneling seguro
2. **Acesso ao RDS** - Conectar a bancos de dados privados
3. **Gerenciamento de EC2 Privadas** - SSH indireto
4. **Deployments Internos** - Executar scripts de deploy
5. **Troubleshooting de Rede** - Diagnosticar problemas internos

## 🎯 Próximas Melhorias

- [ ] Adicionar Elastic IP para IP estático
- [ ] Implementar Auto Scaling Group com health checks
- [ ] Integrar com AWS Systems Manager Session Manager
- [ ] Adicionar CloudWatch logs
- [ ] Configurar VPN alternativa
- [ ] Implementar Bastiones em múltiplas AZs

## 📚 Referências

- [AWS Bastion Host Best Practices](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/)
- [SSH Port Forwarding](https://linux.die.net/man/1/ssh)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

**Autor**: AWS Labs  
**Data**: Janeiro 2026  
**Versão**: 1.0

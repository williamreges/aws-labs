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
```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                         (SSH/TCP:22)
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │    Bastion Host (EC2 - t2.micro)        │
        │  - Público ou com Elastic IP             │
        │  - Acesso SSH liberado                   │
        │  - IAM Role configurada                  │
        └─────────────────────────────────────────┘
                              │
                    (Tunnel SSH Port Forwarding)
                              │
        ┌─────────────────────────────────────────┐
        │    VPC Privada / Recursos Internos      │
        │  - ElastiCache / RDS / Outros EC2       │
        │  - Sem acesso direto da internet        │
        │  - Comunicação através do bastion       │
        └─────────────────────────────────────────┘
```

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
├── main.tf                          # Definição da instância EC2
├── iams.tf                          # Role, Policy e Instance Profile
├── sg.tf                            # Security Groups e Rules
├── variables.tf                     # Variáveis de configuração
├── data.tf                          # Data sources (AMI, VPC, Subnet)
├── locals.tf                        # Valores locais
├── output.tf                        # Outputs do Terraform
├── provider.tf                      # Configuração do provider AWS
├── terraform.tfstate               # Estado atual
├── terraform.tfstate.backup        # Backup do estado
├── iam/
│   ├── policy/
│   │   └── policy-execution-bastion.json    # Permissões da role
│   └── trust/
│       └── trust-execution-bastion.json     # Trust relationship
└── README.md                        # Este arquivo
```

## 🚀 Como Usar

### Pré-requisitos

1. **AWS CLI** configurada com credenciais
2. **Terraform** v1.0+
3. **Key Pair** criada na AWS (especificar o nome em `variables.tf`)
4. **VPC e Subnet** já existentes com as tags configuradas

### Variáveis Principais

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `region` | Região AWS | `sa-east-1` |
| `availability_zone` | Zona de disponibilidade | `sa-east-1a` |
| `name_key_pair` | Nome da Key Pair AWS | Obrigatório |
| `vpc_selected_filter` | Tags para filtrar VPC | `tag:Name = vpc-lab` |
| `public_subnet_selected_filter` | Tags para filtrar Subnet | `tag:Name = public-subnet-1a` |

### Deployment

```bash
# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Planejar deployment
terraform plan

# Aplicar configuração
terraform apply

# Obter informações de output
terraform output
```

### Acessando o Bastion Host

```bash
# 1. Conectar ao bastion via SSH
ssh -i /caminho/para/chave.pem ec2-user@<BASTION_IP>

# 2. Dentro do bastion, conectar ao ElastiCache via port forwarding
ssh -i /caminho/para/chave.pem \
    -L 6379:elasticache-endpoint:6379 \
    ec2-user@<BASTION_IP>

# 3. Em outra sessão local, conectar ao Redis
redis-cli -h localhost -p 6379
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

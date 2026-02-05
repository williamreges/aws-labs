# SQS Standard — Lab 007

Laboratório de AWS SQS usando Terraform para provisionar uma **fila SQS padrão** com **Dead-Letter Queue (DLQ)** e scripts CLI para interação.

## 📋 Visão Geral

Este repositório contém:

1. **Infraestrutura Terraform** (`infra/`) — provisiona uma fila SQS padrão com DLQ e política IAM
2. **Scripts CLI** (`cli/`) — ferramentas bash para enviar, receber e purgar mensagens

### O que é criado

- **Fila SQS Principal** (`lab-sqs-queue`): Fila padrão para envio/recebimento de mensagens
- **Dead-Letter Queue** (`lab-sqs-standard-dlq`): Fila para mensagens não processadas após retries
- **Política IAM** (`policy/policy-sqs.json`): Autoriza ações SQS (SendMessage, ReceiveMessage, DeleteMessage, PurgeQueue, etc.)
- **Política de Redrive**: Máximo de 4 tentativas antes de enviar para DLQ

---

## 📁 Estrutura de Arquivos

```
infra/
├── main.tf                    # Define as filas SQS (principal e DLQ)
├── iams.tf                    # Política IAM para acessar a fila
├── variables.tf               # Variáveis configuráveis (nomes, delays, tags)
├── locals.tf                  # Valores locais (reutilizáveis)
├── provider.tf                # Configuração AWS provider
├── data.tf                    # Data sources (ex: conta AWS)
├── policy/
│   └── policy-sqs.json        # Template de política IAM

cli/
├── sendmessage.sh             # Enviar mensagens para a fila
├── pullmessages.sh            # Receber e deletar mensagens
└── purgemessage.sh            # Purgar todas as mensagens da fila
```

---

## 🔧 Infraestrutura (`infra/`)

### main.tf

Define duas filas SQS:

**Fila Principal** (`aws_sqs_queue.lab-sqs-queue`):
- `delay_seconds`: Atraso antes da mensagem ficar disponível (padrão: 90s)
- `max_message_size`: Tamanho máximo de mensagem em bytes (padrão: 2048)
- `message_retention_seconds`: Tempo de retenção (padrão: 86400 = 1 dia)
- `receive_wait_time_seconds`: Long polling timeout (padrão: 10s)
- `redrive_policy`: Encaminha para DLQ após 4 tentativas falhadas

**Dead-Letter Queue** (`aws_sqs_queue.lab-sqs-queue-dlq`):
- Recebe mensagens que não foram processadas após máximo de retries
- Mesmas configurações de delay/retenção da fila principal

### iams.tf

Define a política SQS via `aws_sqs_queue_policy`:
- Referencia `policy/policy-sqs.json` usando `templatefile()`
- Substitui `${account_id}`, `${region}` e `${queue_name}` no template
- Autoriza ações: SendMessage, ReceiveMessage, DeleteMessage, PurgeQueue, ChangeMessageVisibility, GetQueueAttributes, SetQueueAttributes, GetQueueUrl, DeleteQueue

### variables.tf

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `region` | string | `sa-east-1` | Região AWS |
| `sqs_name` | string | `lab-sqs-queue` | Nome da fila principal |
| `sqs_dlq_name` | string | `lab-sqs-standard-dlq` | Nome da DLQ |
| `tag_environment` | string | `lab` | Tag Environment |
| `sqs_delay_seconds` | number | `90` | Delay da fila principal |
| `sqs_max_message_size` | number | `2048` | Tamanho máx. da fila principal |
| `sqs_message_retention_seconds` | number | `86400` | Retenção da fila principal |
| `sqs_receive_wait_time_seconds` | number | `10` | Long polling da fila principal |
| `dlq_delay_seconds` | number | `90` | Delay da DLQ |
| `dlq_max_message_size` | number | `2048` | Tamanho máx. da DLQ |
| `dlq_message_retention_seconds` | number | `86400` | Retenção da DLQ |
| `dlq_receive_wait_time_seconds` | number | `10` | Long polling da DLQ |

### locals.tf

Define valores reutilizados:
- `label`: prefixo para identificação (`lab`)

### policy/policy-sqs.json

Política IAM em JSON que autoriza a conta AWS root executar:
- `sqs:ListQueues` — listar filas
- `sqs:SendMessage` — enviar mensagens
- `sqs:ReceiveMessage` — receber mensagens
- `sqs:DeleteMessage` — deletar mensagens
- `sqs:PurgeQueue` — purgar a fila
- E outras ações auxiliares (ChangeMessageVisibility, GetQueueAttributes, etc.)

---

## 🎯 Scripts CLI (`cli/`)

Todos os scripts listam filas SQS disponíveis e permitem selecionar a fila alvo.

### sendmessage.sh

**Função**: Enviar uma mensagem para a fila.

**Como usar**:
```bash
cd cli
./sendmessage.sh
```

**Fluxo**:
1. Lista filas SQS disponíveis
2. Você seleciona uma pelo número
3. Digite a mensagem a enviar
4. Mensagem é enviada via `aws sqs send-message`

### pullmessages.sh

**Função**: Receber mensagens da fila e opcionalmente deletá-las.

**Como usar**:
```bash
cd cli
./pullmessages.sh
```

**Fluxo**:
1. Lista filas SQS disponíveis
2. Você seleciona uma
3. Exibe até 10 mensagens (modo tabela)
4. Pergunta se você deseja deletar as mensagens lidas
5. Se sim, deleta os ReceiptHandles das mensagens

### purgemessage.sh

**Função**: Purgar (remover todas) as mensagens da fila.

**Como usar**:
```bash
cd cli
./purgemessage.sh
```

**Fluxo**:
1. Lista filas SQS disponíveis
2. Você seleciona uma
3. Executa `aws sqs purge-queue` para remover todas as mensagens

⚠️ **Cuidado**: Purge é irreversível.

---

## 🚀 Como Usar

### Pré-requisitos

- **Terraform** v1.0+
- **AWS CLI** configurada com credenciais
- **Bash** (Linux/Mac ou Git Bash no Windows)
- Permissões SQS na conta AWS

### Deployment

```bash
cd infra

# Validar configuração
terraform fmt
terraform validate

# Planejar
terraform plan

# Aplicar
terraform apply
```

### Usar os scripts CLI

```bash
cd cli

# Enviar mensagem
./sendmessage.sh

# Receber mensagens
./pullmessages.sh

# Purgar fila
./purgemessage.sh
```

### Cleanup

```bash
cd infra
terraform destroy
```

---

## 📝 Notas Importantes

- **Configuração AWS CLI**: Os scripts CLI requerem credenciais AWS configuradas (`~/.aws/credentials` ou variáveis de ambiente)
- **Redrive Policy**: Mensagens com erro após 4 tentativas são automaticamente enviadas para a DLQ
- **Long Polling**: Default de 10 segundos reduz custos ao esperar mensagens

---

## 🎓 Referências

- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [AWS SQS Pricing](https://aws.amazon.com/sqs/pricing/)
- [Terraform AWS SQS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)

---

**Author**: William Reges  
**Lab**: 007 — SQS Standard  
**Última atualização**: Fevereiro 2026

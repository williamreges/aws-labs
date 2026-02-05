# SQS Standard — Lab 007

AWS SQS laboratory using Terraform to provision a **standard SQS queue** with **Dead-Letter Queue (DLQ)** and CLI scripts for interaction.

## 📋 Overview

This repository contains:

1. **Terraform Infrastructure** (`infra/`) — provisions a standard SQS queue with DLQ and IAM policy
2. **CLI Scripts** (`cli/`) — bash tools to send, receive, and purge messages

### What is created

- **Main SQS Queue** (`lab-sqs-queue`): Standard queue for sending/receiving messages
- **Dead-Letter Queue** (`lab-sqs-standard-dlq`): Queue for unprocessed messages after retries
- **IAM Policy** (`policy/policy-sqs.json`): Authorizes SQS actions (SendMessage, ReceiveMessage, DeleteMessage, PurgeQueue, etc.)
- **Redrive Policy**: Maximum of 4 attempts before sending to DLQ

---

## 📁 File Structure

```
infra/
├── main.tf                    # Defines SQS queues (main and DLQ)
├── iams.tf                    # IAM policy to access the queue
├── variables.tf               # Configurable variables (names, delays, tags)
├── locals.tf                  # Local values (reusable)
├── provider.tf                # AWS provider configuration
├── data.tf                    # Data sources (e.g., AWS account)
├── policy/
│   └── policy-sqs.json        # IAM policy template

cli/
├── sendmessage.sh             # Send messages to the queue
├── pullmessages.sh            # Receive and delete messages
└── purgemessage.sh            # Purge all messages from the queue
```

---

## 🔧 Infrastructure (`infra/`)

### main.tf

Defines two SQS queues:

**Main Queue** (`aws_sqs_queue.lab-sqs-queue`):
- `delay_seconds`: Delay before message becomes available (default: 90s)
- `max_message_size`: Maximum message size in bytes (default: 2048)
- `message_retention_seconds`: Retention time (default: 86400 = 1 day)
- `receive_wait_time_seconds`: Long polling timeout (default: 10s)
- `redrive_policy`: Routes to DLQ after 4 failed attempts

**Dead-Letter Queue** (`aws_sqs_queue.lab-sqs-queue-dlq`):
- Receives messages not processed after maximum retries
- Same delay/retention settings as main queue

### iams.tf

Defines SQS policy via `aws_sqs_queue_policy`:
- References `policy/policy-sqs.json` using `templatefile()`
- Replaces `${account_id}`, `${region}`, and `${queue_name}` in template
- Authorizes actions: SendMessage, ReceiveMessage, DeleteMessage, PurgeQueue, ChangeMessageVisibility, GetQueueAttributes, SetQueueAttributes, GetQueueUrl, DeleteQueue

### variables.tf

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `region` | string | `sa-east-1` | AWS Region |
| `sqs_name` | string | `lab-sqs-queue` | Main queue name |
| `sqs_dlq_name` | string | `lab-sqs-standard-dlq` | DLQ name |
| `tag_environment` | string | `lab` | Environment tag |
| `sqs_delay_seconds` | number | `90` | Main queue delay |
| `sqs_max_message_size` | number | `2048` | Main queue max size |
| `sqs_message_retention_seconds` | number | `86400` | Main queue retention |
| `sqs_receive_wait_time_seconds` | number | `10` | Main queue long polling |
| `dlq_delay_seconds` | number | `90` | DLQ delay |
| `dlq_max_message_size` | number | `2048` | DLQ max size |
| `dlq_message_retention_seconds` | number | `86400` | DLQ retention |
| `dlq_receive_wait_time_seconds` | number | `10` | DLQ long polling |

### locals.tf

Defines reused values:
- `label`: identifier prefix (`lab`)

### policy/policy-sqs.json

IAM policy in JSON authorizing AWS root account to execute:
- `sqs:ListQueues` — list queues
- `sqs:SendMessage` — send messages
- `sqs:ReceiveMessage` — receive messages
- `sqs:DeleteMessage` — delete messages
- `sqs:PurgeQueue` — purge the queue
- And other auxiliary actions (ChangeMessageVisibility, GetQueueAttributes, etc.)

---

## 🎯 CLI Scripts (`cli/`)

All scripts list available SQS queues and allow selecting the target queue.

### sendmessage.sh

**Function**: Send a message to the queue.

**How to use**:
```bash
cd cli
./sendmessage.sh
```

**Flow**:
1. Lists available SQS queues
2. Select one by number
3. Type the message to send
4. Message is sent via `aws sqs send-message`

### pullmessages.sh

**Function**: Receive messages from the queue and optionally delete them.

**How to use**:
```bash
cd cli
./pullmessages.sh
```

**Flow**:
1. Lists available SQS queues
2. Select one
3. Displays up to 10 messages (table mode)
4. Asks if you want to delete the read messages
5. If yes, deletes the ReceiptHandles of messages

### purgemessage.sh

**Function**: Purge (remove all) messages from the queue.

**How to use**:
```bash
cd cli
./purgemessage.sh
```

**Flow**:
1. Lists available SQS queues
2. Select one
3. Executes `aws sqs purge-queue` to remove all messages

⚠️ **Warning**: Purge is irreversible.

---

## 🚀 How to Use

### Prerequisites

- **Terraform** v1.0+
- **AWS CLI** configured with credentials
- **Bash** (Linux/Mac or Git Bash on Windows)
- SQS permissions in AWS account

### Deployment

```bash
cd infra

# Validate configuration
terraform fmt
terraform validate

# Plan
terraform plan

# Apply
terraform apply
```

### Use CLI scripts

```bash
cd cli

# Send message
./sendmessage.sh

# Receive messages
./pullmessages.sh

# Purge queue
./purgemessage.sh
```

### Cleanup

```bash
cd infra
terraform destroy
```

---

## 📝 Important Notes

- **AWS CLI Configuration**: CLI scripts require AWS credentials configured (`~/.aws/credentials` or environment variables)
- **Redrive Policy**: Messages with errors after 4 attempts are automatically sent to DLQ
- **Long Polling**: Default 10 seconds reduces costs by waiting for messages

---

## 🎓 References

- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [AWS SQS Pricing](https://aws.amazon.com/sqs/pricing/)
- [Terraform AWS SQS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)

---

**Author**: William Reges  
**Lab**: 007 — SQS Standard  
**Last updated**: February 2026


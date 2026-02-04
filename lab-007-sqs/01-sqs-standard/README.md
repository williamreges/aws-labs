# Infraestrutura Terraform — SQS Standard

Este diretório contém a infraestrutura criada com Terraform para o laboratório SQS (fila padrão).

## Visão geral

A configuração provisiona os recursos AWS necessários para experimentar uma fila SQS Standard, incluindo políticas IAM e recursos auxiliares utilizados nos exercícios do laboratório.

## Recursos principais criados

- SQS Standard queue — fila padrão do Amazon SQS para envio/recebimento de mensagens.
- IAM policy / roles — políticas que concedem permissões SQS (definidas em `policy/policy-sqs.json`) e vínculos a identidades conforme necessário.
- Security Group — grupo de segurança usado por recursos que requerem conectividade (definido em `sg.tf`).
- Data sources / variáveis / locais — configurações e metadados usados para nomear e parametrizar recursos.

## Arquivos importantes

- `provider.tf` — configuração do provider AWS (credenciais, região).
- `variables.tf` — variáveis de entrada que parametrizam a implantação.
- `locals.tf` — valores locais derivados usados na configuração.
- `data.tf` — data sources usados pela infra (por exemplo, conta, AMIs ou outros dados).
- `main.tf` — definição principal dos recursos (fila SQS e associações).
- `iams.tf` — recursos IAM (políticas e associações); referencia `policy/policy-sqs.json`.
- `sg.tf` — definições de grupos de segurança.
- `output.tf` — outputs exportados (ex.: URL e ARN da fila).
- `policy/policy-sqs.json` — JSON com as permissões SQS necessárias para os exercícios.

## Variáveis e outputs

As variáveis estão em `variables.tf` e permitem customizar nomes, tags e a região. Os outputs em `output.tf` expõem informações úteis como a URL da fila e o ARN, para uso por aplicações ou etapas seguintes do laboratório.

## Como usar

Inicialize e aplique a infraestrutura com os comandos Terraform padrão:

```bash
terraform init
terraform plan -out=plan.tfplan
terraform apply "plan.tfplan"
```

Após a execução, verifique os outputs:

```bash
terraform output
```

Remova a infraestrutura quando terminar:

```bash
terraform destroy -auto-approve
```

## Observações

- A política em `policy/policy-sqs.json` contém as ações SQS necessárias; reveja-a antes de atribuir a identidades em produção.
- Arquivos de estado (`terraform.tfstate`) não devem ser comitados em repositórios públicos.

Se quiser, eu posso também adicionar exemplos de uso da fila (scripts que enviam/recebem mensagens) ou explicar campos específicos de `main.tf` e `iams.tf`.

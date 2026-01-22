#!/bin/bash
echo "=== Exemplo de Conexão SSH ao Bastion ==="

echo "Configurando permissões do arquivo de chave..."

echo "Verificando se o arquivo de chave SSH existe..."

KEY_PAIR="lab-key-pair.pem"

if [ ! -f "$KEY_PAIR" ]; then
    echo "É necessário copiar e colar o arquivo .pem do key pair que está vinculado ao bastion na conta AWS para a pasta corrente do script. Nesse exemplo de laboratório o arquivo é '$KEY_PAIR'"
    echo "Mas você pode usar o nome do arquivo que desejar, desde que atualize a variável KEY_PAIR desse script e no terraform resourece bastion_public_instance-key_name"
    echo "O arquivo de chave deve estar no mesmo diretório que este script para que a conexão SSH com o bastion host funcione corretamente."
    echo "Erro: arquivo de chave SSH '$KEY_PAIR' não encontrado!"
    exit 1
fi

sudo chmod 400 "$KEY_PAIR"

sleep 1

echo "Buscando o IP público da instância bastion-host..."

# Get the public IP of the bastion host EC2 instance
BASTION_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=bastion-host" "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Validando se o IP foi obtido com sucesso..."
if [ -z "$BASTION_IP" ] || [ "$BASTION_IP" = "None" ]; then
    echo "Error: Could not find running bastion-host instance"
    exit 1
fi

echo "Bastion IP: $BASTION_IP"

echo " === Dentro do bastion, conecte à instância privada com:"
echo "ssh ec2-user@<IP_PRIVADO>"
echo ""
echo "Iniciando conexão SSH ao bastion..."

# Update the SSH command with the dynamic IP
ssh -A -i "$KEY_PAIR" ec2-user@"$BASTION_IP"

#!/bin/bash

#==========================DECLARE=================================
export NOME_RECURSO=validadigitocpffunction
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);

#==========================BEGIN=====================================
echo "Lambda: $NOME_RECURSO"
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "

sleep 3

# Verificando se a policy já existe
ARN_POLICY=$(aws iam list-policies --scope=Local \
                --query 'Policies[?PolicyName==`aws-lambda-'${NOME_RECURSO}'-custom-policy`].Arn' \
                --output text \
                --profile $PROFILE);

if [ $ARN_POLICY ]; then
  echo "Policy e Role já existem e não precisa ser recriado"
  exit;
fi

echo "=== CRIACAO DE POLICY aws-lambda-validadigitocpffunction-custom-policy ==="
aws iam create-policy \
    --policy-name aws-lambda-${NOME_RECURSO}-custom-policy \
    --policy-document file://policy.json \
    --description "This policy grants access to all Put CloudWatch" \
    --profile $PROFILE

sleep 3

echo ""
echo "=== CRIACAO DE ROLE aws-lambda-validadigitocpffunction-custom-role ==="
aws iam create-role \
    --role-name aws-lambda-${NOME_RECURSO}-custom-role \
    --assume-role-policy-document file://policy-trust.json \
    --profile $PROFILE

echo ""
echo "=== ANEXANDO POLICY A ROLE aws-lambda-validadigitocpffunction-custom-role==="
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::$CONTA_AWS:policy/aws-lambda-${NOME_RECURSO}-custom-policy \
    --role-name aws-lambda-validadigitocpffunction-custom-role \
    --profile $PROFILE

#==========================END==============================================
echo "=== FIM ==="
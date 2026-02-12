
#==========================DECLARE=================================
export NOME_RECURSO=validadigitocpffunction

export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text );

#==========================BEGIN=====================================
echo "Lambda: $NOME_RECURSO"

echo "Conta AWS: $CONTA_AWS "


# Verificando se lambda existe
ARN_LAMBDA=$(aws lambda get-function \
              --function-name $NOME_RECURSO \
              --query Configuration.FunctionArn \
              --output text);

if [ $ARN_LAMBDA ]; then
        echo "=== DELETANDO FUNCTION LAMBDA  ==="
        aws lambda delete-function \
            --function-name ${NOME_RECURSO}
        echo "=== LAMBDA DELETADO COM EXITO ==="
fi

# Verificando se a policy já existe
ARN_POLICY=$(aws iam list-policies --scope=Local \
                --query 'Policies[?PolicyName==`aws-lambda-'${NOME_RECURSO}'-custom-policy`].Arn' \
                --output text );

if [ $ARN_POLICY ]; then
    echo "=== DELETANDO ROLE E POLICY==="
    aws iam delete-role-policy \
        --role-name aws-lambda-${NOME_RECURSO}-custom-role \
        --policy-name aws-lambda-${NOME_RECURSO}-custom-policy
    echo "=== ROLE E POLICY DELETADO COM EXITO==="
fi

# Deletando a IAM Role
if [ $ARN_POLICY ]; then
    echo "=== DELETANDO IAM ROLE ==="
    aws iam delete-role \
        --role-name aws-lambda-${NOME_RECURSO}-custom-role
    echo "=== IAM ROLE DELETADO COM EXITO ==="
fi

# Deletando a Policy
if [ $ARN_POLICY ]; then
    echo "=== DELETANDO POLICY ==="
    aws iam delete-policy \
        --policy-arn $ARN_POLICY
    echo "=== POLICY DELETADO COM EXITO ==="
fi
#==========================END=================================




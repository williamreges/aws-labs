
#==========================DECLARE=================================
export NOME_RECURSO=validadigitocpffunction
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);

#==========================BEGIN=====================================
echo "Lambda: $NOME_RECURSO"
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "


# Verificando se lambda existe
ARN_LAMBDA=$(aws lambda get-function \
              --function-name $NOME_RECURSO \
              --query Configuration.FunctionArn \
              --output text \
              --profile $PROFILE);

if [ $ARN_LAMBDA ]; then
        echo "=== DELETANDO FUNCTION LAMBDA  ==="
        aws lambda delete-function \
            --function-name ${NOME_RECURSO} \
            --profile $PROFILE
        echo "=== LAMBDA DELETADO COM EXITO ==="
fi

# Verificando se a policy já existe
ARN_POLICY=$(aws iam list-policies --scope=Local \
                --query 'Policies[?PolicyName==`aws-lambda-'${NOME_RECURSO}'-custom-policy`].Arn' \
                --output text \
                --profile $PROFILE);

if [ $ARN_POLICY ]; then
    echo "=== DELETANDO ROLE E POLICY==="
    aws iam delete-role-policy \
        --role-name aws-lambda-${NOME_RECURSO}-custom-role \
        --policy-name aws-lambda-${NOME_RECURSO}-custom-policy \
        --profile $PROFILE
    echo "=== ROLE E POLICY DELETADO COM EXITO==="
fi

#==========================END=================================




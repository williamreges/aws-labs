
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
  echo "=== CRIANDO FUNCTION LAMBDA  ==="

  aws lambda update-function-code \
      --function-name  ${NOME_RECURSO}  \
      --zip-file fileb://app.jar \
      --profile $PROFILE

  echo "=== FUNCTION LAMBDA CRIADO ==="
fi

#==========================END=====================================




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
  echo "=== ATUALIZANDO FUNCTION LAMBDA  ==="

  aws lambda update-function-code \
      --function-name  ${NOME_RECURSO}  \
      --zip-file fileb://app.jar

  echo "=== FUNCTION LAMBDA ATUALIZADO COM SUCESSO ==="
fi

#==========================END=====================================



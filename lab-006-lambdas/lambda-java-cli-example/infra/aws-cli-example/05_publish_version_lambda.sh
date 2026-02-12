
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
              --output text );

if [ $ARN_LAMBDA ]; then
  echo "=== CREATE VERSION FUNCTION LAMBDA  ==="

  bash 02_maven_package.sh
  bash 04_update_latest_lambda.sh

  aws lambda publish-version \
      --function-name $NOME_RECURSO

  echo "=== VERSION FUNCTION LAMBDA CREATE SUCCESS==="
fi

#==========================END=====================================



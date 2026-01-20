
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
  echo "=== INVOKE SUFIX FUNCTION LAMBDA  ==="


echo "=== LISTA DE ALIASES E EXISTENTES ==="
aws lambda list-aliases --function-name ${NOME_RECURSO} --output table --profile $PROFILE
echo "=== LISTA DE VERSOES E EXISTENTES ==="
aws lambda list-versions-by-function --function-name ${NOME_RECURSO} --query 'Versions[*].Version' --output table --profile $PROFILE

  echo ""
  read -p "Informe a versão ou um Alias a ser invocada: " SUFIX

  if [ $SUFIX ]; then
      aws lambda invoke \
            --function-name ${NOME_RECURSO}:$SUFIX \
            --cli-binary-format raw-in-base64-out \
            --payload '{ "cpf": "aaaa" }' \
            response.json --profile $PROFILE

      sleep 3

      echo $(cat response.json)
  fi

  echo "=== FUNCTION LAMBDA INVOKE ==="
fi

#==========================END=====================================



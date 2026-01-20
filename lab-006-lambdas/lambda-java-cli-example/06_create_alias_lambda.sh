
#==========================DECLARE=================================
export NOME_RECURSO=validadigitocpffunction
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
ALIASES=("DEV" "HOM" "PROD")

#==========================BEGIN=====================================
echo "Lambda: $NOME_RECURSO"
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "

echo "=== LISTA DE ALIASES E EXISTENTES ==="
aws lambda list-aliases --function-name ${NOME_RECURSO} --output table --profile $PROFILE

# Verificando se lambda existe
ARN_LAMBDA=$(aws lambda get-function \
              --function-name $NOME_RECURSO \
              --query Configuration.FunctionArn \
              --output text \
              --profile $PROFILE);

if [ $ARN_LAMBDA ]; then
  echo "=== CREATE ALIAS FUNCTION LAMBDA  ==="

  echo "Escolha um ALIAS padrão abaixo: "
  # shellcheck disable=SC2068
  select alias in ${ALIASES[@]}; do
      case $alias in
        DEV | HOM | PROD)
          echo "Alias ${alias} selecionado."
          # shellcheck disable=SC2034
          ALIAS_CHOOSE=${alias}
          ;;
        *)
          echo "Alias Inválido. Selecione novamente: "
          continue ;;
      esac

      break
  done

  echo "Escolha uma versão abaixo para anexar ao ALIAS: "
  VAR_VERSIONS_LIST=$(aws lambda list-versions-by-function --function-name ${NOME_RECURSO} --query 'Versions[*].Version' --output text --profile $PROFILE)
  select version_exist in ${VAR_VERSIONS_LIST[*]}; do
      VERSION_CHOOSE=$version_exist;
      break
  done


  if [ $ALIAS_CHOOSE ]; then

    aws lambda create-alias \
          --function-name ${NOME_RECURSO} \
          --description "alias for live version of function" \
          --function-version $VERSION_CHOOSE \
          --name $ALIAS_CHOOSE \
          --profile $PROFILE
    fi

  echo "=== ALIAS ${ALIAS} FUNCTION LAMBDA CREATE SUCCESS==="
fi

#==========================END=====================================



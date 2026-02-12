
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
    echo "Funcao Lambda ${NOME_RECURSO} já existe";
    exit;
fi

echo "=== CRIANDO FUNCTION LAMBDA  ==="
aws lambda create-function --function-name ${NOME_RECURSO} \
--runtime java17 --handler org.example.GeneratorDigitoCpfHandler::handleRequest \
--role arn:aws:iam::${CONTA_AWS}:role/aws-lambda-${NOME_RECURSO}-custom-role \
--zip-file fileb://app.jar \
--profile $PROFILE
echo "=== FUNCTION LAMBDA CRIADO ==="


#============================END=========================================


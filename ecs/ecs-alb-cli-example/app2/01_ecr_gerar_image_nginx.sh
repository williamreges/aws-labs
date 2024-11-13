echo "=== START PROCCESS ECR ==="

#==================DECLARE============================================================================
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
export NOME_APP=app2
export REGIAO=sa-east-1

#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Nome do Repositório ECR: $NOME_APP"


echo "Logando no ECR com o Docker"
aws ecr get-login-password --region $REGIAO --profile $PROFILE | docker login --username AWS --password-stdin $CONTA_AWS.dkr.ecr.$REGIAO.amazonaws.com

echo"Obtem ARN do Repositório $NOME_APP se existir..."
ARN_REPOSITORY=$(aws ecr describe-repositories --query "repositories[?repositoryName=='$NOME_APP'].repositoryArn" --profile $PROFILE --output text)
echo " - ARN do Repositório ECR: $ARN_REPOSITORY"

if [ ! $ARN_REPOSITORY ]; then
    echo "Criando Repositório no ECR..."
    aws ecr create-repository \
        --repository-name $NOME_APP \
        --profile $PROFILE
    sleep 5
    echo "...Repositório criado no ECR com sucesso..."
fi

echo " CRIANDO A IMAGEM $NOME_APP ..."
docker build -t $NOME_APP .

echo " TAGUEANDO A IMAGEM $NOME_APP ..."
docker tag $NOME_APP:latest $CONTA_AWS.dkr.ecr.$REGIAO.amazonaws.com/$NOME_APP:latest

echo " ENVIANDO A IMAGEM $NOME_APP para o ECR"
docker push $CONTA_AWS.dkr.ecr.$REGIAO.amazonaws.com/$NOME_APP:latest

#===================END===============================================================================
echo "=== END PROCCESS ECR ==="
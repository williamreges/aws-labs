echo "=== START PROCCESS CLUSTER ECS FORGATE ==="

#==================DECLARE============================================================================
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
export CLUSTER_NAME=app-cluster
export PROVIDER=FARGATE

#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Nome do Cluster $CLUSTER_NAME"
echo "Capacidade Provida: $PROVIDER"


echo "Obtendo Cluster Existente ..."
CLUSTER_ECS=$(aws ecs describe-clusters  --include ATTACHMENTS --clusters $CLUSTER_NAME1 --profile $PROFILE)
echo " - Detelhes do Cluster=  $CLUSTER_ECS"

if [ ! $CLUSTER_ECS ]; then
  echo " - Criando Cluster ECS..."
    aws ecs create-cluster \
        --cluster-name $CLUSTER_NAME \
        --capacity-providers=$PROVIDER \
        --default-capacity-provider-strategy capacityProvider=$PROVIDER,weight=1 \
        --profile $PROFILE
    sleep 10
    echo "...Cluster ECS criado com sucesso."
else
  echo " - Cluster ECS $CLUSTER_NAME já existe"
fi
#===================END===============================================================================
echo "=== END PROCCESS CLUSTER ECS FORGATE ==="
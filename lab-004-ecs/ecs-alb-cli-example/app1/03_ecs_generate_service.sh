#!/bin/bash

echo "=== START PROCCESS SERVICE==="

#==================DECLARE============================================================================
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);

export REGIAO_A=sa-east-1a
export REGIAO_C=sa-east-1c
export SG_DEFAULT=default
export SG_WEB=aulaaws-security-web

export NAME_TASKDEFINITION=app1-task
export CLUSTER_NAME=app-cluster
export PROVIDER=FARGATE
export SERVICE=service-app1


#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Familia da Task: $NAME_TASKDEFINITION"


echo "=== Obtendo Grupos de Segurança ==="
SG_DEFAULT_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$SG_DEFAULT'].GroupId" --output text --profile $PROFILE)
#SG_WEB_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$SG_WEB'].GroupId" --output text --profile $PROFILE)

echo "=== Obtendo Subnets Padrão ==="
SUBNETID_A=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$REGIAO_A'].SubnetId" --output text --profile $PROFILE)
SUBNETID_C=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$REGIAO_C'].SubnetId" --output text --profile $PROFILE)

echo "Obtendo o Task Definition Latest..."
ARN_TASK_DEFINITION=$(aws ecs list-task-definitions \
                          --family-prefix $NAME_TASKDEFINITION \
                          --sort DESC \
                          --query taskDefinitionArns[0] \
                          --output text \
                          --profile $PROFILE)

echo " - ARN do Task Definition Latest: $ARN_TASK_DEFINITION"

LATEST_TASK_DEFINITION=$(echo $ARN_TASK_DEFINITION | cut -d '/' -f 2)
echo " - Task Definitio Latest: $LATEST_TASK_DEFINITION"

echo "Criando Service $SERVICE ..."
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE \
    --task-definition $LATEST_TASK_DEFINITION \
    --desired-count 1 \
    --capacity-provider-strategy capacityProvider=$PROVIDER,weight=1 \
    --platform-version LATEST \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNETID_A, $SUBNETID_C],securityGroups=[$SG_DEFAULT_ID]}" \
    --enable-execute-command \
    --tags key=key1,value=value1 key=key2,value=value2 key=key3,value=value3 \
    --profile $PROFILE

echo "...Service $SERVICE finalizado"


#===================END===============================================================================
echo "=== END PROCCESS ECS ==="
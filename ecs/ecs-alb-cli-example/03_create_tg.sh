echo "=== START PROCCESS TARGET GROUP ==="
#==================DECLARE============================================================================

export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
export TG_NOME=tg-app

#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Nome do Target Group: $TG_NOME"


echo "Obtendo ARN do Target Group Existente..."
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$TG_NOME'].TargetGroupArn" --output text --profile $PROFILE)
echo $TARGET_GROUP_ARN


if [ ! $TARGET_GROUP_ARN ]; then

  echo "=== Obtendo VPC Padrão para anexar ao novo Target Group..."
  VPC=$(aws ec2 describe-vpcs --query "Vpcs[?InstanceTenancy=='default'].VpcId" --output text --profile $PROFILE)
  echo $VPC

  echo " - Criando Target Group..."
    aws elbv2 create-target-group --name $TG_NOME --protocol HTTP --port 80 \
    --vpc-id $VPC \
    --ip-address-type ipv4 \
    --profile $PROFILE

  echo " ...Target Group $TG_NOME criado com sucesso"
  sleep 10
else
  echo " - Target Group $TG_NOME existe e não precisa ser recriado"
fi
#===================END===============================================================================
echo "=== END PROCCESS TARGET GROUP ==="
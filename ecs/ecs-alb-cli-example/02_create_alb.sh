echo "=== START PROCCESS LOAD BALANCER ==="
#==================DECLARE============================================================================
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
export REGIAO_A=sa-east-1a
export REGIAO_C=sa-east-1c
export LB_NOME=lb-app
export SG_DEFAULT=default
export SG_WEB=aulaaws-security-web

#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Nome da Regiao A: $REGIAO_A"
echo "Nome da Regiao C: $REGIAO_C"
echo "Nome do Load Balancer: $LB_NOME"
echo "Nome do Security Group Default: $SG_DEFAULT"
echo "Nome do Security Group WEB: $SG_WEB"

ARN_LB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$LB_NOME'].LoadBalancerArn" --output text --profile $PROFILE)

if [ ! $ARN_LB ]; then

  echo "=== Obtendo Grupos de Segurança ==="
  SG_DEFAULT_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$SG_DEFAULT'].GroupId" --output text --profile $PROFILE)
  SG_WEB_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$SG_WEB'].GroupId" --output text --profile $PROFILE)

  echo "=== Obtendo Subnets Padrão ==="
  SUBNETID_A=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$REGIAO_A'].SubnetId" --output text --profile $PROFILE)
  SUBNETID_C=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$REGIAO_C'].SubnetId" --output text --profile $PROFILE)

  echo " - Criando Application Load Balancer ..."
  aws elbv2 create-load-balancer --name $LB_NOME \
  --subnets $SUBNETID_A $SUBNETID_C \
  --security-groups $SG_DEFAULT_ID $SG_WEB_ID \
  --profile $PROFILE
  echo " ... Application Load Balancer criado com sucesso"

  sleep 60
else
  echo " - Load Balancer $LB_NOME já existe e não precisa ser recriado."
fi

#===================END===============================================================================
echo "=== END PROCCESS LOAD BALANCER ==="


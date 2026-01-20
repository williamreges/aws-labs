echo "=== START PROCCESS LISTENER==="
#==================DECLARE============================================================================

export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
export LB_NOME=lb-app
export TG_NOME=tg-app

#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Nome do Load Balancer: $LB_NOME"
echo "Nome do Target Group: $TG_NOME"


echo "Obtendo ARN do Target Group Existente..."
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$TG_NOME'].TargetGroupArn" --output text --profile $PROFILE)
echo " - Target Group: $TARGET_GROUP_ARN"


if [ $TARGET_GROUP_ARN ]; then

  echo "Obtendo ARN do LoadBalancer Existente..."
  ARN_LB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$LB_NOME'].LoadBalancerArn" --output text --profile $PROFILE)
  echo " - ARN do Load Balancer: $ARN_LB"

  echo "Obtendo Listener Existente..."
  LISTENER=$(aws elbv2 describe-listeners --load-balancer-arn $ARN_LB --output text --profile $PROFILE)
  echo $LISTENER

    if [ ! $LISTENER ]; then
     echo " - Criando Listener para o Target Group..."

     aws elbv2 create-listener --load-balancer-arn $ARN_LB \
     --protocol HTTP --port 80  \
     --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN \
     --profile $PROFILE

     sleep 5
     echo "...Listener Criado com sucesso"
    else
        echo " - Listener para o Target Group $TG_NOME já existe"
    fi

fi
#===================END===============================================================================
echo "=== END PROCCESS LISTENER ==="
echo "=== START PROCCESS TASK DEFINITION ==="

#==================DECLARE============================================================================
export PROFILE=aulaaws
export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
export NAME_TASKDEFINITION=app2-task


#===================BEGIN ============================================================================
echo "Profile: $PROFILE"
echo "Conta AWS: $CONTA_AWS "
echo "Familia da Task: $NAME_TASKDEFINITION"


echo "Obtendo ARN da Task Definition $NAME_TASKDEFINITION"
ARN_TASKDEFINITION=$(aws ecs list-task-definitions --family-prefix $NAME_TASKDEFINITION --output text --profile $PROFILE)
echo "- ARN da TaskDefinition: $ARN_TASKDEFINITION"

echo "Criando TaskDefinition $NAME_TASKDEFINITION"
aws ecs register-task-definition --cli-input-json file://fargate-task.json --profile $PROFILE


#===================END===============================================================================
echo "=== END PROCCESS TASK DEFINITION ==="
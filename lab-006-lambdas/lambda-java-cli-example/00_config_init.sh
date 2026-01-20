echo "=== CONFIG VARIAVEIS ==="

export NOME_RECURSO=validadigitocpffunction
echo "Lambda: $NOME_RECURSO"

export PROFILE=aulaaws
echo "Profile: $PROFILE"

export CONTA_AWS=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE);
echo "Conta AWS: $CONTA_AWS "

echo "=== FIM ==="

echo "=== Criando pacote Maven ==="
mvn clean install -f ./validadigitocpffunction/pom.xml

echo "=== Gerando ZIP lambdafunction.zip"
#cp ./validadigitocpffunction/target/aws-lambda-validadigitocpffunction-1.0-SNAPSHOT.jar ./app.jar
cp ./validadigitocpffunction/target/aws-lambda-validadigitocpffunction-1.0-SNAPSHOT.jar ../infra/aws-cli/app.jar
cp ./validadigitocpffunction/target/aws-lambda-validadigitocpffunction-1.0-SNAPSHOT.jar ../infra/terraform/code/app.jar

echo "=== Zip Gerado ==="
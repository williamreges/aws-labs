
echo "=== Criando pacote Maven ==="
mvn clean install -f $(pwd)/validadigitocpffunction/pom.xml

echo "=== Gerando ZIP lambdafunction.zip"
mv $(pwd)/validadigitocpffunction/target/aws-lambda-validadigitocpffunction-1.0-SNAPSHOT.jar ./app.jar
echo "=== Zip Gerado ==="
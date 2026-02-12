
echo "=== Criando pacote Maven ==="
mvn clean install -f ../../app/validadigitocpffunction/pom.xml

echo "=== Gerando ZIP lambdafunction.zip"
mv ../../app/validadigitocpffunction/target/aws-lambda-validadigitocpffunction-1.0-SNAPSHOT.jar ./app.jar
echo "=== Zip Gerado ==="
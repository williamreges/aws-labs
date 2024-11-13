package org.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Optional;

public class GeneratorDigitoCpfHandler implements RequestHandler<Pessoa, String> {

    private static final CalcularDACUtils calcularDACUtils = new CalcularDACUtils();

    @Override
    public String handleRequest(Pessoa pessoa, Context context) {
        final var logger = context.getLogger();
        logger.log("CPF sem digito: ".concat(pessoa.cpf()));

        final var cpfComDigito = Optional.ofNullable(pessoa)
                .map(Pessoa::cpf)
                .map(calcularDACUtils::calcularDAC)
                .orElseThrow(RuntimeException::new);

        logger.log("CPF gerado com digito: ".concat(cpfComDigito));
        return cpfComDigito;
    }
}


package org.example;

import java.util.Optional;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class CalcularDACUtils {

    public String calcularDAC(final String cpf) {

        final int numberFirstDV = buildFirstDV(cpf);
        final int numberSecondDV = buildSecondDV(cpf + numberFirstDV);

        return cpf + numberFirstDV + numberSecondDV;
    }

    private int buildFirstDV(String cpf) {
        final int[] digitos = buildDigitsCPF(cpf);

        final var soma =
                IntStream
                        .range(0, 9)
                        .map(cont -> Math.multiplyExact(digitos[cont], (cont + 1)))
                        .reduce(0, Math::addExact);

        return buildResultDigitDV(soma);

    }

    private int buildSecondDV(String cpf) {
        int[] digitos = buildDigitsCPF(cpf);

        var soma =
                IntStream
                        .range(0, 10)
                        .map(cont -> Math.multiplyExact(digitos[cont], cont))
                        .reduce(0, Math::addExact);

        return buildResultDigitDV(soma);
    }

    private int buildResultDigitDV(int soma) {
        final var mod = Math.floorMod(soma, 11);

        return Optional
                .ofNullable(mod)
                .filter(result -> result < 10)
                .orElse(0);
    }

    private int[] buildDigitsCPF(String cpf) {
        return Stream.of(cpf.split(""))
                .mapToInt(Integer::valueOf)
                .toArray();
    }
}

package org.example;

import java.io.IOException;
import java.util.Properties;

public class Property {

    public static String getProperti(String chave) {
        final var inputStream = Property.class.getClassLoader().getResourceAsStream("config.properties");
        final var properties = new Properties();
        try {
            properties.load(inputStream);
            var valor = properties.getProperty(chave);
            return valor;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}

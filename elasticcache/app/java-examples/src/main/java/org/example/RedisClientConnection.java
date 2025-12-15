package org.example;

import io.lettuce.core.RedisClient;
import io.lettuce.core.api.sync.RedisCommands;

public class RedisClientConnection {
    public static void main(String[] args) {
        // URI de conexão ao ElasticCache
        String uri = "redis://lab-redis-cluster.jhuwus.0001.sae1.cache.amazonaws.com:6379";

        RedisClient client = RedisClient.create(uri);
        RedisCommands<String, String> commands = client.connect().sync();

        try {
            String pong = commands.ping();
            System.out.println("Conexão bem-sucedida: " + pong);

            commands.set("chave", "valor");
            String valor = commands.get("chave");
            System.out.println("Valor recuperado: " + valor);
        } finally {
            client.shutdown();
        }
    }
}
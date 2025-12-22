
# ElasticCache com Redis

## Introdução

Amazon ElasticCache é um serviço web que facilita a implantação, operação e escala de um cache em memória na nuvem. O Redis é um armazenamento de dados em memória de código aberto que suporta várias estruturas de dados.

## O que é ElasticCache?

ElasticCache é um serviço gerenciado que oferece:
- **Desempenho em tempo real** com latência de milissegundos
- **Alta disponibilidade** com replicação automática
- **Escalabilidade** horizontal e vertical
- **Compatibilidade** com Redis e Memcached

## Redis no ElasticCache

### Características Principais

- Cache distribuído em memória
- Suporte a estruturas de dados: Strings, Lists, Sets, Hashes, Sorted Sets
- Persistência opcional (RDB e AOF)
- Replicação mestre-escravo
- Cluster automático

### Casos de Uso

- Cache de sessões
- Armazenamento em cache de resultados de consultas
- Pub/Sub em tempo real
- Leaderboards e análises em tempo real

## Primeiros Passos

1. Criar um cluster ElasticCache com Redis
2. Configurar grupos de segurança
3. Conectar aplicações ao endpoint
4. Monitorar performance via CloudWatch


## AWS CLI - Comandos Essenciais

### Listar Clusters ElasticCache
```bash
aws elasticache describe-cache-clusters --region sa-east-1
```

### Listar com Detalhes Completos
```bash
aws elasticache describe-cache-clusters --show-cache-node-info --region sa-east-1
```

### Descrever um Cluster Específico
```bash
aws elasticache describe-cache-clusters --cache-cluster-id lab-redis-cluster --region sa-east-1
```

### Criar um Cluster Redis
```bash
aws elasticache create-cache-cluster \
    --cache-cluster-id my-redis-cluster \
    --engine redis \
    --cache-node-type cache.t3.micro \
    --engine-version 7.0 \
    --num-cache-nodes 1 \
    --region sa-east-1
```

### Deletar um Cluster
```bash
aws elasticache delete-cache-cluster --cache-cluster-id my-redis-cluster --region sa-east-1
```

### Listar Grupos de Parâmetros
```bash
aws elasticache describe-cache-parameter-groups --region sa-east-1
```

### Obter Endpoint do Cluster
```bash
aws elasticache describe-cache-clusters --cache-cluster-id lab-redis-cluster --show-cache-node-info --query 'CacheClusters[0].CacheNodes[0].Endpoint' --region sa-east-1
```

### Obter ReplicationGroups dos Clusters
```bash
 aws elasticache describe-replication-groups --region sa-east-1
```

## Exemplo de Conexão Java com Jedis

```java
import redis.clients.jedis.Jedis;

public class JedisConnection {
    public static void main(String[] args) {
        Jedis jedis = new Jedis(
                new HostAndPort("lab-redis-cluster.jhuwus.0001.sae1.cache.amazonaws.com", 6379));
//        jedis.auth("1234!");
        jedis.ttl("50000");

        String response = jedis.ping();
        System.out.println("Conexão: " + response);

        jedis.set("chave-jedis", "valor-jedis");
        String valor = jedis.get("chave-jedis");
        System.out.println("Valor: " + valor);

        jedis.close();
    }
}
```

**Dependência Maven:**
```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>7.0.0</version>
</dependency>
```


**Com Connection Pool:**
```java
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

JedisPoolConfig config = new JedisPoolConfig();
JedisPool pool = new JedisPool(config, host, port);

try (Jedis jedis = pool.getResource()) {
    jedis.set("chave", "valor");
}
```

## Exemplo de Conexão Java com RedisClient

Para conectar a um cluster ElasticCache Redis na AWS usando Lettuce (RedisClient):

```java
import io.lettuce.core.RedisClient;
import io.lettuce.core.api.sync.RedisCommands;

public class RedisClientConnection {
    public static void main(String[] args) {

        RedisClient client = RedisClient.create(RedisURI.Builder
                .redis("lab-redis-cluster.jhuwus.0001.sae1.cache.amazonaws.com")
                .withSsl(false)
//                .withPassword("1234!")
                .withDatabase(0)
                .build());
        StatefulRedisConnection<String, String> connection = client.connect();
        RedisCommands<String, String> commands = connection.sync();
        try {
            String pong = commands.ping();
            System.out.println("Conexão bem-sucedida: " + pong);

            commands.set("chave-lettuce", "valor-lettuce");
            String valor = commands.get("chave-lettuce");
            System.out.println("Valor recuperado: " + valor);
        } finally {
            client.shutdown();
        }
    }
}
```

**Dependência Maven:**
```xml
<dependency>
    <groupId>io.lettuce</groupId>
    <artifactId>lettuce-core</artifactId>
    <version>7.1.0.RELEASE</version>
</dependency>
```

**Com Connection Pool:**
```java
import io.lettuce.core.RedisClient;
import io.lettuce.core.support.ConnectionPoolSupport;
import org.apache.commons.pool2.impl.GenericObjectPool;

RedisClient client = RedisClient.create(uri);
GenericObjectPool<StatefulRedisConnection<String, String>> pool = 
    ConnectionPoolSupport.createGenericObjectPool(
        () -> client.connect(), 
        new GenericObjectPoolConfig<>()
    );
```

## Exemplo de Conexão com Redisson

Para conectar a um cluster ElasticCache Redis na AWS usando Redisson:

```java
import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;

public class RedissonConnection {
    public static void main(String[] args) {
        Config config = new Config();
        config.useSingleServer()
            .setAddress("redis://seu-endpoint.xxxxx.ng.amazonaws.com:6379");
        
        RedissonClient redisson = Redisson.create(config);
        
        try {
            redisson.getKeys().flushall();
            redisson.getBucket("chave").set("valor");
            String valor = redisson.getBucket("chave").get();
            System.out.println("Valor recuperado: " + valor);
        } finally {
            redisson.shutdown();
        }
    }
}
```

**Dependência Maven:**
```xml
<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson</artifactId>
    <version>3.52.0</version>
</dependency>
```

**Com Cluster:**
```java
Config config = new Config();
config.useClusterServers()
    .addNodeAddress("redis://node1.xxxxx.ng.amazonaws.com:6379")
    .addNodeAddress("redis://node2.xxxxx.ng.amazonaws.com:6379");

RedissonClient redisson = Redisson.create(config);
```

## Terraform - Recurso provisionado na AWS

### Elasticache Redis com 1 nó
![exemplo de cache no console aws](image.png)

## Recursos

- [Documentação AWS ElasticCache](https://docs.aws.amazon.com/elasticache/)
- [Redis Documentation](https://redis.io/documentation)
- [Terraform Elasticache Cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster)
- [Spring Data Redis](https://docs.spring.io/spring-data/redis/reference/redis.html)

### AWS Session Manager
- [Working with Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with.html)
- [Start Session](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html)



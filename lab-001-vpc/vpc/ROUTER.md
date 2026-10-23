# 🧭 Entendendo as Rotas de uma VPC na AWS

Este documento explica duas rotas comuns em uma tabela de rotas da Amazon Web Services (AWS):

- `10.0.0.0/16 → local`
- `0.0.0.0/0 → igw-xxxxxxxx`

O exemplo considera uma VPC com CIDR `10.0.0.0/16` e uma sub-rede `10.0.2.0/24`.

## 1. 🗺️ O que é uma tabela de rotas?

Uma tabela de rotas contém regras que determinam para onde a AWS deve encaminhar o tráfego de rede que sai de uma sub-rede. Cada rota tem, principalmente:

- **Destino:** faixa de endereços IP para a qual a regra se aplica.
- **Alvo (target):** próximo destino para onde o tráfego deve ser encaminhado.

Quando mais de uma rota corresponde ao endereço de destino, a AWS utiliza a rota mais específica (a que corresponde à faixa mais estreita).

## 2. 🏠 Rota local: `10.0.0.0/16 → local`

Essa rota permite o encaminhamento de tráfego entre recursos dentro da mesma VPC, conforme as demais regras de rede.

Uma VPC com CIDR `10.0.0.0/16` abrange endereços IPv4 de `10.0.0.0` a `10.0.255.255`. Uma sub-rede `10.0.2.0/24` está dentro dessa faixa.

Exemplo de sub-redes dentro da VPC:

| Sub-rede | CIDR |
|---|---|
| Sub-rede A | `10.0.1.0/24` |
| Sub-rede B | `10.0.2.0/24` |
| Sub-rede C | `10.0.3.0/24` |

Se uma instância na Sub-rede A enviar tráfego para uma instância na Sub-rede B, o destino `10.0.2.15` corresponde à rota local `10.0.0.0/16 → local`.

**Importante:** a rota local não libera todo o tráfego automaticamente. Security Groups, Network ACLs, firewalls dos sistemas operacionais e a configuração dos serviços ainda podem permitir ou bloquear a comunicação.

## 3. 🌐 Rota padrão IPv4: `0.0.0.0/0 → igw-xxxxxxxx`

`0.0.0.0/0` representa todos os destinos IPv4. Em uma tabela de rotas, costuma ser usada como **rota padrão**: o tráfego cujo destino não corresponda a uma rota mais específica pode seguir para o alvo indicado.

O alvo `igw-xxxxxxxx` representa o ID de um **Internet Gateway (IGW)**. Um Internet Gateway permite a comunicação entre a VPC e a internet, mas a existência dessa rota, sozinha, não garante que uma instância esteja acessível pela internet.

Para acesso IPv4 direto à internet, verifique também:

1. O Internet Gateway está anexado à VPC correta.
2. A tabela de rotas com a rota para o IGW está associada à sub-rede.
3. A instância possui um IPv4 público ou Elastic IP, quando necessário para comunicação direta com a internet.
4. O Security Group permite o tráfego necessário.
5. A Network ACL permite o tráfego de entrada, saída e retorno necessário.
6. O firewall do sistema operacional e o serviço de destino estão configurados corretamente.

## 4. 📋 Exemplo de tabela de rotas

| Destino | Alvo | Finalidade |
|---|---|---|
| `10.0.0.0/16` | `local` | Encaminhar tráfego destinado à faixa da VPC |
| `0.0.0.0/0` | `igw-xxxxxxxx` | Encaminhar outros destinos IPv4 para o Internet Gateway |

### 🔎 Qual rota será usada?

Considerando essa tabela:

| IP de destino | Rota selecionada | Motivo |
|---|---|---|
| `10.0.3.10` | `10.0.0.0/16 → local` | O IP está dentro da faixa da VPC |
| `8.8.8.8` | `0.0.0.0/0 → igw-xxxxxxxx` | O IP não pertence à faixa `10.0.0.0/16` |
| `142.250.79.14` | `0.0.0.0/0 → igw-xxxxxxxx` | O IP não pertence à faixa da VPC |

A AWS escolhe a rota correspondente mais específica. Portanto, as duas rotas não são usadas simultaneamente para decidir o mesmo encaminhamento.

## 5. 📡 Como uma sub-rede se torna pública?

Uma sub-rede é considerada pública quando sua tabela de rotas tem uma rota para um Internet Gateway. Para que uma instância nessa sub-rede se comunique diretamente com a internet por IPv4, outras condições também precisam ser atendidas, como endereço IP público e regras de segurança apropriadas.

No exemplo:

- **VPC:** `10.0.0.0/16`
- **Sub-rede pública:** `10.0.2.0/24`
- **Rota local:** `10.0.0.0/16 → local`
- **Rota para internet:** `0.0.0.0/0 → igw-xxxxxxxx`

O nome da sub-rede, como `public-subnet-1a`, é apenas um rótulo. O que importa é a configuração efetiva da tabela de rotas e dos recursos de rede.

### 🔄 IP público automático

A opção de atribuição automática de IPv4 público determina se novas instâncias lançadas na sub-rede recebem automaticamente um IPv4 público, salvo configurações específicas que alterem esse comportamento. Ativá-la não atribui automaticamente um endereço público a todas as instâncias que já existem.

## 6. 🔀 Diferença entre sub-rede pública e privada

### 🌍 Sub-rede pública

Normalmente tem uma rota padrão IPv4 para um Internet Gateway:

```text
0.0.0.0/0 → igw-xxxxxxxx
```

Uma instância precisa das configurações de endereçamento e segurança adequadas para acessar ou receber conexões da internet.

### 🔒 Sub-rede privada

Não tem uma rota direta para um Internet Gateway. Se precisar de acesso de saída à internet, pode usar, por exemplo, um NAT Gateway localizado em uma sub-rede pública:

```text
0.0.0.0/0 → nat-xxxxxxxx
```

O NAT Gateway permite que recursos privados iniciem conexões de saída, sem que precisem receber conexões iniciadas diretamente da internet por meio dele.

## 7. 🛠️ Checklist para diagnosticar problemas

Se a instância não conseguir acessar a internet, confira:

- [ ] A tabela de rotas correta está associada à sub-rede?
- [ ] Existe a rota `0.0.0.0/0` apontando para o Internet Gateway correto?
- [ ] O Internet Gateway está anexado à VPC?
- [ ] A instância tem IPv4 público ou Elastic IP, se necessário?
- [ ] O Security Group permite o tráfego exigido?
- [ ] A Network ACL permite tráfego de entrada, saída e portas efêmeras de retorno quando aplicável?
- [ ] O firewall do sistema operacional permite a conexão?
- [ ] O serviço que você está tentando acessar está em execução e escutando na porta correta?

## ✅ Resumo

- `10.0.0.0/16 → local`: encaminha tráfego destinado à faixa da própria VPC.
- `0.0.0.0/0 → igw-xxxxxxxx`: é a rota padrão para destinos IPv4 fora das rotas mais específicas e direciona o tráfego ao Internet Gateway.
- A rota para o IGW é necessária para uma sub-rede pública IPv4, mas não basta, por si só, para garantir conectividade com a internet.
- A AWS seleciona a rota correspondente mais específica; as rotas não são aplicadas simultaneamente ao mesmo encaminhamento.

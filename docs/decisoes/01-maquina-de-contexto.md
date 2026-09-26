# Decisão 01 — Máquina de contexto + máquina de sistema

## Status

Aceita.

## Contexto

`Blablacar.mch` hoje concentra `SETS`, `CONSTANTS`, `PROPERTIES`, `VARIABLES`, `INVARIANT` e `OPERATIONS` numa única máquina. Isso funciona para o esqueleto da E1, mas dois fatores pesam para separar antes de continuar:

- Geração automática de código (etapa 4 do projeto) exige que conjuntos adiados (`USERS`, `TRIPS`, `LOCATIONS`, `REQUESTS`) e constantes (`min_score`, `max_seats`) recebam valor concreto numa **implementação**. Fazer isso dentro da própria implementação de `Blablacar` mistura o que é parâmetro fixo do domínio com o que é lógica de negócio.
- Refinamento não pode alterar assinatura de operação. Os `SETS`/`CONSTANTS` que hoje estão soltos em `Blablacar.mch` vão ser vistos por qualquer máquina futura (ex.: se o sistema for quebrado em componentes no refinamento); centralizá-los agora evita redeclaração ou divergência depois.

## Decisão

Extrair uma máquina de contexto, vista (`SEES`) pela máquina de sistema:

- **Contexto** (`Contexto.mch` ou nome equivalente): `SETS` (`USERS`, `TRIPS`, `LOCATIONS`, `REQUESTS`, `TRIP_STATUS`, `REQ_STATUS`), `CONSTANTS` (`min_score`, `max_seats`), `PROPERTIES` (`min_score : 0..5`, `max_seats : NAT1`, `max_seats = 8`, `min_score = 3`).
- **Sistema** (`Blablacar.mch`): `VARIABLES`, `INVARIANT`, `INITIALISATION`, `OPERATIONS`. Passa a ter `SEES Contexto` em vez de declarar `SETS`/`CONSTANTS`/`PROPERTIES` localmente.

Não se cria mais de uma máquina de sistema nesta etapa. Usuários, viagens, pedidos e histórico continuam numa única `Blablacar`, porque as regras que os conectam (ocupação = soma das vagas aceitas, aceite que lota vira `full` e recusa `pending` restantes, cancelamento que devolve vaga) atravessam esses dados e ficariam mais difíceis de expressar e animar se partidas em máquinas `INCLUDES`/`IMPORTS` nesta fase. Divisão em componentes fica em aberto para o refinamento (entrega 2), se fizer sentido depois de ter os corpos das operações completos.

## Motivos (resumo)

1. **Só leitura vs. estado**: contexto é parâmetro do domínio (não muda em tempo de execução); máquina de sistema é o que varia. Separar deixa essa fronteira explícita no próprio código B, não só na documentação.
2. **Reuso sem redeclaração**: qualquer máquina que precisar de `USERS`/`TRIPS`/`max_seats`/etc. usa `SEES Contexto`, sem repetir `SETS`/`CONSTANTS`.
3. **Caminho de implementação mais limpo**: o contexto ganha sua própria implementação (conjuntos adiados → portador finito concreto) antes ou em paralelo à implementação de `Blablacar`, isolando essa tradução do resto da lógica.
4. **Estabilidade de assinatura**: como `PROPERTIES` e `CONSTANTS` não mudam entre abstrata → refinamento → implementação, mantê-las num componente separado reduz o risco de alterar algo que teria efeito cascata nas assinaturas das operações.
5. **Boas práticas do método B**: a dica do professor ("use máquinas de contexto e as implemente antes de continuar o desenvolvimento") é o padrão usual quando há `SETS`/`CONSTANTS`/`PROPERTIES` não triviais — que é o nosso caso (5 sets, 2 constantes com restrição de tipo).

## Consequências

- `Blablacar.mch` perde as seções `SETS`/`CONSTANTS`/`PROPERTIES` e ganha `SEES Contexto` no topo.
- Um novo arquivo `Contexto.mch` entra no repositório, sem `VARIABLES` nem `OPERATIONS`.
- Nenhuma pré-condição, invariante ou animação já feita na E1 muda de comportamento; é reorganização estrutural, não muda semântica do sistema.
- Entrega 1 (apresentação) segue com a máquina abstrata dividida assim: mostra-se `Contexto.mch` + `Blablacar.mch` como a "visão geral da máquina abstrata".
- Entrega 2: implementação de `Contexto.mch` concretiza os conjuntos adiados; implementação/refinamento de `Blablacar` parte desse contexto já concreto.

## Alternativas consideradas

- **Manter tudo em `Blablacar.mch`**: mais simples agora, mas empurra a separação para quando já houver mais operações e invariantes, tornando a extração mais arriscada.
- **Quebrar também o sistema em várias máquinas de dados (usuários / viagens / pedidos)**: rejeitado nesta etapa — as regras de ocupação, aceite e cancelamento acoplam esses dados fortemente; a separação ganha mais sentido no refinamento.

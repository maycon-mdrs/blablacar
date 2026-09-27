# Visão do modelo — primeira entrega

Desenho da máquina abstrata completa (README §§1–9). O [`Blablacar.mch`](../Blablacar.mch) de hoje só tem o trecho de usuários e `create_trip`, ainda com `skip`. Os desenhos abaixo são o alvo dessa primeira entrega, como está fatiado em [`docs/entregas`](entregas/).

Cada seta com nome de operação é uma chamada da máquina. Consultas (`remaining_seats`, `is_verified`, …) só leem; não aparecem nas transições.

## 1. O que existe no estado

Três “fichas”. A seta é uma função do B: a ficha da esquerda é a chave, a da direita é o valor guardado. `occupation` não aponta para pedidos; é o contador de vagas já reservadas, e tem de bater com a soma das vagas dos pedidos `accepted` daquela viagem.

```mermaid
flowchart LR
  subgraph usuario ["usuário cadastrado em users"]
    verified["verified → BOOL"]
    score["score → 0..5"]
  end

  subgraph viagem ["viagem em trips"]
    driver["driver → usuário"]
    origin["origin → local"]
    destination["destination → local"]
    seats["seats → 1..max_seats"]
    price["price → NAT"]
    trip_status["trip_status"]
    occupation["occupation → NAT"]
  end

  subgraph pedido ["pedido em requests"]
    req_passenger["req_passenger → usuário"]
    req_trip["req_trip → viagem"]
    req_seats["req_seats → NAT"]
    req_status["req_status"]
  end

  driver -.-> usuario
  req_passenger -.-> usuario
  req_trip -.-> viagem
```

As linhas pontilhadas seguem a mesma regra chave→valor: `driver` e `req_passenger` valem um usuário; `req_trip` vale uma viagem.

O histórico não é uma quarta ficha solta: é a lista ordenada das viagens que já estão `finished` (`history_len` e `history_at(i)`).

## 2. Status da viagem

`create_trip` faz a viagem nascer `open`. Aceitar não muda o status enquanto ainda sobrar vaga. Quando a ocupação fica igual à capacidade, ela passa a `full` e os outros pedidos `pending` dessa viagem vão para `refused`.

```mermaid
stateDiagram-v2
  [*] --> open: create_trip
  open --> open: accept_request sem lotar
  open --> full: accept_request lota
  full --> open: cancel_request de um accepted libera vaga
  open --> cancelled: cancel_trip
  full --> cancelled: cancel_trip
  open --> ongoing: start_trip
  full --> ongoing: start_trip
  ongoing --> finished: finish_trip
```

`start_trip` só sai de `open` ou `full` se já houver pelo menos 1 vaga ocupada. `cancel_trip` não existe a partir de `ongoing` nem de `finished`.

## 3. Status do pedido

O pedido nasce `pending`. `accepted` continua `accepted` depois que a viagem inicia e quando ela termina: o passageiro não “sai” do pedido ao concluir. `ongoing`, `finished` e `cancelled` é que não podem ter `pending`.

```mermaid
stateDiagram-v2
  [*] --> pending: request_ride
  pending --> accepted: accept_request ou auto_accept_fitting
  pending --> refused: refuse_request
  pending --> refused: viagem lotou ou start_trip
  pending --> cancelled_req: cancel_request ou cancel_trip
  accepted --> cancelled_req: cancel_request ou cancel_trip
```

`request_ride` só em viagem `open`, com passageiro verificado, nota ≥ `min_score`, que não seja o motorista, sem outro pedido `pending` ou `accepted` na mesma viagem, e pedindo no máximo a capacidade da viagem.

## 4. Caminho da apresentação

Um cenário só, na ordem em que vale animar no ProB. Dois usuários, uma viagem de 2 vagas, o passageiro pede as 2, o aceite lota, a viagem anda e entra no histórico.

```mermaid
sequenceDiagram
  actor Motorista
  actor Passageiro
  participant M as Blablacar

  Motorista->>M: register, verify_user
  Passageiro->>M: register, verify_user
  Motorista->>M: create_trip (2 vagas)
  Note over M: viagem open, occupation 0
  Passageiro->>M: request_ride (2 vagas)
  Note over M: pedido pending
  Motorista->>M: accept_request
  Note over M: pedido accepted, viagem full, occupation 2
  Motorista->>M: start_trip
  Note over M: ongoing
  Motorista->>M: finish_trip
  Note over M: finished, history_at(1) = essa viagem
```

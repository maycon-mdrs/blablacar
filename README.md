# Plataforma de caronas (estilo BlaBlaCar)

Sistema de caronas compartilhadas em que motoristas publicam viagens e passageiros solicitam vagas, com verificação de perfil, pontuação e controle de ocupação por quantidade de assentos.

---

## 1. Usuários

- Qualquer pessoa pode se cadastrar.
- Depois do cadastro, o perfil pode ser verificado.
- Todo usuário tem uma pontuação de **0 a 5**.

### Requisitos por papel

| Ação | Requisitos |
|------|------------|
| Pedir carona (passageiro) | Estar verificado **e** pontuação ≥ mínima definida no sistema |
| Criar viagem (motorista) | Estar verificado |

---

## 2. Criar viagem

O motorista cria uma viagem com:

- origem
- destino
- quantidade de vagas
- preço por vaga

### Regras

- origem e destino **não podem ser iguais**
- vagas entre **1** e um máximo definido no sistema (ex.: 8)
- a viagem nasce como **open** (já disponível para pedidos)

---

## 3. Pedido de carona

Passageiro solicita vaga(s) numa viagem **open**, informando quantas vagas quer (ex.: 2, se for casal/família).

### Regras

- não pode pedir vaga na **própria** viagem
- não pode ter mais de um pedido ativo (**pending** ou **accepted**) na mesma viagem
- a quantidade pedida **não pode passar** da capacidade total da viagem
- só pede se ainda houver **pelo menos 1** vaga livre
- pedido começa como **pending**

---

## 4. Aceitar / recusar

O motorista responde o pedido:

| Ação | Efeito |
|------|--------|
| **accept** | As vagas pedidas são reservadas de uma vez (não dá para aceitar só parte do pedido) |
| **refuse** | Pedido recusado |

### Regras

- só aceita pedido **pending**
- só aceita se as vagas pedidas **couberem** no espaço restante da viagem
- a ocupação da viagem é controlada por um **contador** (não é mais “1 pedido = 1 vaga”)
- se ao aceitar a viagem **lotar exatamente**:
  - vira **full**
  - pedidos **pending** restantes dessa viagem são **recusados automaticamente**
- existe uma operação que escolhe automaticamente um pedido pendente que ainda caiba no espaço restante (**não determinismo**)

---

## 5. Cancelamentos

### Cancelar pedido

- passageiro/sistema pode cancelar pedido **pending** ou **accepted**
- se era **accepted**, libera de volta a quantidade de vagas daquele pedido
- se a viagem estava **full**, volta para **open**

### Cancelar viagem

- motorista pode cancelar se estiver **open** ou **full**
- ao cancelar, todos os pedidos ativos da viagem vão para **cancelled_req**
- **não** cancela viagem já em andamento ou concluída (fora do escopo atual)

---

## 6. Iniciar e concluir

### Iniciar

- só se a viagem estiver **open** ou **full**
- precisa ter **pelo menos 1** vaga ocupada
- status vira **ongoing**
- pedidos ainda **pending** são recusados

### Concluir

- só viagem **ongoing**
- status vira **finished**
- a viagem entra no **histórico** (em ordem)

---

## 7. Status

### Viagem

| Status | Significado |
|--------|-------------|
| `open` | Criada, com vaga |
| `full` | Lotada |
| `ongoing` | Em andamento |
| `finished` | Concluída |
| `cancelled` | Cancelada |

### Pedido

| Status | Significado |
|--------|-------------|
| `pending` | Esperando resposta |
| `accepted` | Aceito |
| `refused` | Recusado |
| `cancelled_req` | Cancelado |

---

## 8. Invariantes

- origem ≠ destino
- motorista **nunca** é passageiro da própria viagem
- vagas pedidas em um pedido ≤ capacidade total da viagem
- ocupação da viagem ≤ número de assentos (mesmo com pedidos de várias vagas)
- `open` ⇒ ainda tem vaga livre
- `full` ⇒ ocupação = capacidade total
- viagem em andamento / concluída / cancelada ⇒ sem pedidos pendentes
- histórico só tem viagens `finished`

---

## 9. Consultas

A máquina de estados / modelo deve permitir consultar:

- vagas restantes
- se o usuário é verificado
- pontuação do usuário
- status da viagem / do pedido
- quantidade de vagas pedidas em um pedido
- lista de passageiros aceitos
- motorista / origem / destino / preço
- histórico e posição no histórico

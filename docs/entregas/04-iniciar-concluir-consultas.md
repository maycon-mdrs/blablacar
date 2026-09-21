# E4 — Iniciar / concluir + status + consultas

## 1. Range

Outline — [README](../../README.md) **§§6–9** (ciclo de vida restante, consolidação de status, consultas).

Depende de **E2/E3** (ocupação, pedidos, cancelamentos).

---

## 2. SETS / CONSTANTS

Reutiliza `TRIP_STATUS` / `REQ_STATUS` já introduzidos. Sem sets novos obrigatórios.

---

## 3. VARIABLES (novas)

| Variável | Intenção |
|----------|----------|
| `history_len` | Tamanho do histórico (`NAT`) |
| `history_at` | Função `1..history_len --> TRIPS` (posição → viagem `finished`) |

Status `ongoing` e `finished` passam a ser alcançáveis via operações desta entrega.

> O histórico é estado interno indexado; **operações** nunca recebem nem devolvem a sequência inteira.

---

## 4. INVARIANT (a acrescentar)

- Viagem `ongoing` / `finished` / `cancelled` ⇒ sem pedidos `pending`
- Domínio de `history_at` = `1..history_len`; imagem ⊆ viagens com `trip_status = finished`
- Ordem do histórico preservada (append ao concluir: `history_len := history_len + 1` e `history_at(history_len) := t`)
- Demais invariantes de §7–§8 já cobertos em E1–E3 permanecem

---

## 5. OPERATIONS (esqueleto previsto)

Assinaturas **concretas** (só escalares); ver [convenção](README.md#assinaturas-concretas).

### Ciclo de vida

| Operação | Pré-condições / efeito |
|----------|-------------------------|
| `start_trip(t)` | status `open` ou `full`; `occupation(t) >= 1`; → `ongoing`; pedidos `pending` da viagem → `refused` |
| `finish_trip(t)` | status `ongoing`; → `finished`; append de `t` no histórico |

### Consultas (§9) — leitura com retorno escalar

| Operação | Retorno | Significado |
|----------|---------|-------------|
| `nn <-- remaining_seats(t)` | `NAT` | `seats(t) - occupation(t)` |
| `bb <-- is_verified(u)` | `BOOL` | `verified(u)` |
| `nn <-- user_score(u)` | `0..5` | `score(u)` |
| `st <-- get_trip_status(t)` | `TRIP_STATUS` | `trip_status(t)` |
| `st <-- get_req_status(r)` | `REQ_STATUS` | `req_status(r)` |
| `nn <-- get_req_seats(r)` | `NAT` | `req_seats(r)` |
| `bb <-- is_accepted_on(t, u)` | `BOOL` | `TRUE` se existe pedido `accepted` de `u` em `t` |
| `dd <-- get_driver(t)` | `USERS` | motorista |
| `oo <-- get_origin(t)` | `LOCATIONS` | origem |
| `de <-- get_destination(t)` | `LOCATIONS` | destino |
| `pp <-- get_price(t)` | `NAT` | preço por vaga |
| `nn <-- history_length` | `NAT` | `history_len` |
| `tt <-- history_at(i)` | `TRIPS` | viagem na posição `i` (`i : 1..history_len`) |
| `nn <-- history_position(t)` | `NAT` | índice de `t` no histórico (`t` já `finished`) |

Corpos podem permanecer `skip` até a implementação da E4 no `.mch` (para consultas, o `THEN` futuro atribui o escalar de saída).

---

## 6. Fora de escopo

- Alteração de pontuação pós-viagem (não especificado no README)
- Novos fluxos além do README
- Operações que devolvam conjuntos, sequências ou registros compostos

---

## 7. Checklist ProB

- [ ] `start_trip` exige ocupação ≥ 1 e status `open`/`full`
- [ ] Ao iniciar, não restam `pending`
- [ ] `finish_trip` só de `ongoing` e inclui no histórico
- [ ] Histórico só com `finished`; `history_at(i)` / `history_position(t)` coerentes
- [ ] Consultas cobrem a lista do §9 com retornos escalares
- [ ] Nenhuma assinatura usa conjunto / sequência / tupla

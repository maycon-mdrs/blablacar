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
| `history` | Sequência / lista ordenada de viagens `finished` |

Status `ongoing` e `finished` passam a ser alcançáveis via operações desta entrega.

---

## 4. INVARIANT (a acrescentar)

- Viagem `ongoing` / `finished` / `cancelled` ⇒ sem pedidos `pending`
- Histórico só contém viagens com `trip_status = finished`
- Ordem do histórico preservada (append ao concluir)
- Demais invariantes de §7–§8 já cobertos em E1–E3 permanecem

---

## 5. OPERATIONS (esqueleto previsto)

### Ciclo de vida

| Operação | Pré-condições / efeito |
|----------|-------------------------|
| `start_trip(t)` | status `open` ou `full`; `occupation(t) >= 1`; → `ongoing`; pedidos `pending` da viagem → `refused` |
| `finish_trip(t)` | status `ongoing`; → `finished`; append de `t` em `history` |

### Consultas (§9) — operações de leitura

| Operação | Retorno pretendido |
|----------|--------------------|
| `remaining_seats(t)` | `seats(t) - occupation(t)` |
| `is_verified(u)` | `verified(u)` |
| `user_score(u)` | `score(u)` |
| `get_trip_status(t)` | `trip_status(t)` |
| `get_req_status(r)` | `req_status(r)` |
| `get_req_seats(r)` | `req_seats(r)` |
| `accepted_passengers(t)` | passageiros com pedido `accepted` em `t` |
| `trip_info(t)` | motorista / origem / destino / preço |
| `history_list` / `history_position(t)` | histórico e posição |

Formato exato (operações `out <-- name(...)` vs. expressões só no ProB) a definir na implementação da E4.

---

## 6. Fora de escopo

- Alteração de pontuação pós-viagem (não especificado no README)
- Novos fluxos além do README

---

## 7. Checklist ProB

- [ ] `start_trip` exige ocupação ≥ 1 e status `open`/`full`
- [ ] Ao iniciar, não restam `pending`
- [ ] `finish_trip` só de `ongoing` e inclui no histórico
- [ ] Histórico só com `finished`
- [ ] Consultas cobrem a lista do §9

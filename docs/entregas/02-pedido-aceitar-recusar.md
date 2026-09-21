# E2 — Pedido de carona + Aceitar / recusar

## 1. Range

Outline — [README](../../README.md) **§§3–4** (+ invariantes de ocupação/pedidos do §8).

Depende de **E1** (usuários verificados, viagens `open`).

---

## 2. SETS / CONSTANTS

| Item | Papel |
|------|--------|
| `REQUESTS` | Identificadores de pedidos |
| `REQ_STATUS = {pending, accepted, refused, cancelled_req}` | Status de pedido |

Constantes já existentes: `min_score`, `max_seats`.

---

## 3. VARIABLES (novas)

| Variável | Intenção |
|----------|----------|
| `requests` | Pedidos existentes |
| `req_trip` | Pedido → viagem |
| `req_passenger` | Pedido → usuário |
| `req_seats` | Quantidade de vagas pedidas |
| `req_status` | Status do pedido |
| `occupation` | Já em E1; passa a ser atualizado no aceite |

---

## 4. INVARIANT (a acrescentar)

- Motorista nunca é passageiro da própria viagem
- `req_seats(r) <= seats(req_trip(r))`
- `occupation(t) <= seats(t)`
- `open` ⇒ ainda há vaga livre (`occupation < seats`)
- `full` ⇒ `occupation = seats`
- `draft` ⇒ ocupação 0 e sem pedidos ativos
- No máximo um pedido ativo (`pending` ou `accepted`) por (passageiro, viagem)
- Pedidos só em viagens que aceitam passageiros (`open` / regras de aceite)

---

## 5. OPERATIONS (esqueleto previsto)

| Operação | Pré-condições principais |
|----------|--------------------------|
| `request_ride(r, t, p, n)` | viagem `open`; `p` verificado; `score(p) >= min_score`; `p /= driver(t)`; sem pedido ativo na mesma viagem; `n <= seats(t)`; há ≥ 1 vaga livre; pedido nasce `pending` |
| `accept_request(r)` | `pending`; vagas pedidas cabem no restante; reserva total; se lotar → `full` + recusar outros `pending` |
| `refuse_request(r)` | pedido `pending` → `refused` |
| `auto_accept_fitting` | **não-determinismo**: escolhe um `pending` que ainda caiba |

Corpos podem permanecer `skip` até a implementação da E2 no `.mch`.

---

## 6. Fora de escopo

- Cancelar pedido / viagem → **E3**
- `ongoing` / `finished` / histórico / consultas → **E4**

---

## 7. Checklist ProB

- [ ] Pedido na própria viagem bloqueado
- [ ] Pedido duplicado ativo bloqueado
- [ ] Aceite que lotar exatamente → `full` + pending recusados
- [ ] Animar `auto_accept_fitting` (vários pending elegíveis)

# E2 — Pedido de carona + Aceitar / recusar

## 1. Range

Implementado em [`Blablacar.mch`](../../Blablacar.mch) — [README](../../README.md) **§§3–4** (+ invariantes de ocupação/pedidos do §8).

Depende de **E1** (usuários verificados, viagens `open`).

---

## 2. SETS / CONSTANTS

Nenhum set novo. `REQUESTS` e `REQ_STATUS = {pending, accepted, refused, cancelled_req}` já estão em [`Blablacar_ctx.mch`](../../Blablacar_ctx.mch), junto com `min_score` e `max_seats`. Esta entrega só acrescenta variáveis e operações de pedido em `Blablacar`.

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
- No máximo um pedido ativo (`pending` ou `accepted`) por (passageiro, viagem)
- Pedidos só em viagens que aceitam passageiros (`open` / regras de aceite)

---

## 5. OPERATIONS

| Operação | Pré-condições | Efeito (implementado) |
|----------|---------------|------------------------|
| `request_ride(rr, tt, uu, nn)` | viagem `open`; `uu` verificado; `score(uu) >= min_score`; `uu /= driver(tt)`; sem pedido ativo na mesma viagem; `nn <= seats(tt)`; há ≥ 1 vaga livre | pedido nasce `pending`, com viagem, passageiro e quantidade gravados |
| `accept_request(rr)` | pedido `pending`; vagas pedidas cabem no restante | reserva todas as vagas; se a ocupação fica igual à capacidade, a viagem vai para `full` e os outros `pending` dessa viagem passam a `refused` |
| `refuse_request(rr)` | pedido `pending` | `req_status(rr) := refused` |
| `auto_accept_fitting` | existe um `pending` que ainda cabe | o mesmo efeito de `accept_request`; o `ANY` escolhe qual pedido, se houver mais de um |

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

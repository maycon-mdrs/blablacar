# E3 — Cancelamentos

## 1. Range

Outline — [README](../../README.md) **§5**.

Depende de **E2** (pedidos com status e ocupação).

---

## 2. SETS / CONSTANTS

Nenhum set novo obrigatório. Reutiliza `REQ_STATUS` (`cancelled_req`) e `TRIP_STATUS` (`cancelled`).

---

## 3. VARIABLES

Sem variáveis novas previstas; efeito sobre:

- `req_status`
- `occupation`
- `trip_status` (`full` → `open` ao liberar vagas; viagem → `cancelled`)

---

## 4. INVARIANT (a reforçar)

- Cancelar pedido `accepted` restaura ocupação coerente (`occupation <= seats`)
- Se viagem estava `full` e liberou vaga → volta a `open`
- Viagem `cancelled` ⇒ pedidos ativos da viagem em `cancelled_req` (sem `pending`/`accepted`)
- Não cancelar viagem `ongoing` / `finished` (guards; fora do escopo atual do domínio)

---

## 5. OPERATIONS (esqueleto previsto)

| Operação | Pré-condições / efeito |
|----------|-------------------------|
| `cancel_request(r)` | `req_status(r) : {pending, accepted}`; se `accepted`, libera `req_seats(r)` na ocupação; se ficou vaga e status era `full` → `open`; pedido → `cancelled_req` |
| `cancel_trip(t)` | `trip_status(t) : {draft, open, full}`; viagem → `cancelled`; todos os pedidos ativos da viagem → `cancelled_req` |

---

## 6. Fora de escopo

- Iniciar / concluir viagem → **E4**
- Histórico e consultas → **E4**
- Cancelamento de viagem já em andamento ou concluída (explicitamente fora)

---

## 7. Checklist ProB

- [ ] Cancelar `pending` não altera ocupação
- [ ] Cancelar `accepted` reduz ocupação e pode reabrir `full` → `open`
- [ ] `cancel_trip` marca viagem e pedidos ativos corretamente
- [ ] Guards bloqueiam cancelar `ongoing` / `finished`

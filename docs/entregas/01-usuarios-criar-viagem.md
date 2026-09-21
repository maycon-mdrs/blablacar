# E1 — Usuários + Criar viagem

## 1. Range

Cobre o [README](../../README.md):

- **§1 Usuários** — cadastro, verificação, pontuação 0–5; requisito “verificado” para criar viagem
- **§2 Criar viagem** — origem, destino, vagas, preço; nasce `open`

**Artefato:** [`Blablacar.mch`](../../Blablacar.mch) (esqueleto com `skip`).

---

## 2. SETS / CONSTANTS

### SETS

| Set | Papel |
|-----|--------|
| `USERS` | Identificadores de usuários |
| `TRIPS` | Identificadores de viagens |
| `LOCATIONS` | Locais (origem/destino) |
| `TRIP_STATUS` | `{ open, full, ongoing, finished, cancelled }` — enum completo já declarado; E1 só usa `open` |

### CONSTANTS

| Constante | Significado | Restrição típica |
|-----------|-------------|------------------|
| `min_score` | Pontuação mínima para pedir carona (passageiro) | `min_score : 0..5` |
| `max_seats` | Máximo de vagas por viagem | `max_seats : NAT1` (ex.: 8) |

> `min_score` é declarado na E1 (domínio de usuário), mas a operação de pedir carona só aparece na E2.

---

## 3. VARIABLES

| Variável | Tipo (intenção) | Significado |
|----------|-----------------|-------------|
| `users` | `POW(USERS)` | Usuários cadastrados |
| `verified` | `users --> BOOL` (ou `POW(users)`) | Perfil verificado |
| `score` | `users --> 0..5` | Pontuação |
| `trips` | `POW(TRIPS)` | Viagens existentes |
| `driver` | `trips --> users` | Motorista da viagem |
| `origin` | `trips --> LOCATIONS` | Origem |
| `destination` | `trips --> LOCATIONS` | Destino |
| `seats` | `trips --> 1..max_seats` | Capacidade (vagas) |
| `price` | `trips --> NAT` | Preço por vaga |
| `trip_status` | `trips --> TRIP_STATUS` | Status da viagem |
| `occupation` | `trips --> NAT` | Contador de ocupação (E1: 0 ao criar) |

Estado ainda **não** modelado (E2+): pedidos, passageiros aceitos, histórico.

---

## 4. INVARIANT

### Texto (subset do §8 + tipagem)

- Domínio coerente: `verified`, `score` só para usuários em `users`; atributos de viagem só para `trips`.
- Pontuação ∈ `0..5`.
- Capacidade ∈ `1..max_seats`.
- Origem ≠ destino para toda viagem.
- Em E1, viagens criadas nascem `open` (já disponíveis para pedidos nas entregas seguintes).
- Status usados de fato na E1: apenas `open` (outros valores do enum ficam para entregas seguintes).

### Esboço B

```
users <: USERS &
verified : users --> BOOL &
score : users --> 0..5 &
trips <: TRIPS &
driver : trips --> users &
origin : trips --> LOCATIONS &
destination : trips --> LOCATIONS &
seats : trips --> 1..max_seats &
price : trips --> NAT &
trip_status : trips --> TRIP_STATUS &
occupation : trips --> NAT &
!t.(t : trips => origin(t) /= destination(t)) &
!t.(t : trips => trip_status(t) = open)
```

Invariantes de pedidos / motorista-não-passageiro / `open`⇔vaga livre / `full` ficam para E2+.

---

## 5. OPERATIONS

Todas com corpo `skip` nesta entrega (guards documentadas para animação futura).

### Usuários

| Operação | Pré-condições (intenção) |
|----------|---------------------------|
| `register(u)` | `u : USERS` ∧ `u /: users` |
| `verify_user(u)` | `u : users` ∧ `verified(u) = FALSE` (ou `u` ainda não verificado) |

Pontuação inicial: na implementação futura do corpo, tipicamente `score(u) := 0` no cadastro. Sem operação de alterar score na E1.

### Viagens

| Operação | Pré-condições (intenção) |
|----------|---------------------------|
| `create_trip(t, d, o, dest, n, p)` | `t : TRIPS` ∧ `t /: trips` ∧ `d : users` ∧ `verified(d) = TRUE` ∧ `o : LOCATIONS` ∧ `dest : LOCATIONS` ∧ `o /= dest` ∧ `n : 1..max_seats` ∧ `p : NAT` |

Efeitos esperados (quando o corpo deixar de ser `skip`):

- `create_trip` → inclui `t` em `trips`, preenche atributos, `trip_status(t) = open`, `occupation(t) = 0`

---

## 6. Fora de escopo

- Pedido de carona e regras de pontuação mínima do passageiro → **E2**
- Aceitar / recusar, lotação `full`, não-determinismo → **E2**
- Cancelamentos → **E3**
- Iniciar / concluir, histórico, consultas completas → **E4**
- Corpos das operações (`THEN` com atribuições)

---

## 7. Checklist ProB

- [ ] Carregar `Blablacar.mch` sem erro de sintaxe
- [ ] Inicialização (`INITIALISATION`) deixa invariantes verdadeiros
- [ ] Animar `register` → `verify_user` → `create_trip`
- [ ] Recusar (guard falso) `create_trip` com origem = destino
- [ ] Recusar `create_trip` com motorista não verificado
- [ ] Confirmar que corpos ainda são `skip` (estado não muda nas ops — esperado nesta fase)

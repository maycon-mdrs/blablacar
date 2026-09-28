# Como ler o B deste projeto

Guia do que já está em [`Blablacar_ctx.mch`](../Blablacar_ctx.mch) (sets, constantes e propriedades) e em [`Blablacar.mch`](../Blablacar.mch) (estado e operações). Não é um manual da linguagem: só o vocabulário que aparece nesses arquivos, em português, na ordem em que as máquinas são lidas. O desenho do sistema completo da primeira entrega está em [visão do modelo](visao-do-modelo.md).

Uma máquina B não é um programa que “roda linha a linha”. É um contrato:

- o **estado** é o valor atual das variáveis;
- o **invariante** é o que tem de ser verdade em todo estado observável;
- cada **operação** só pode ser chamada se a pré-condição for verdadeira, e o corpo tem de deixar o invariante verdadeiro de novo.

O ProB anima esse contrato (mostra estados e quais operações estão habilitadas). O Atelier-B gera obrigações de prova: “essa operação realmente preserva o invariante?”.

## As seções, de cima para baixo

| Seção | Onde está | O que é | Muda durante a animação? |
|-------|-----------|---------|--------------------------|
| `SEES` | `Blablacar` | Liga a máquina de sistema ao contexto | Não |
| `SETS` | `Blablacar_ctx` | Universos de identificadores e enums | Não |
| `CONSTANTS` / `PROPERTIES` | `Blablacar_ctx` | Parâmetros fixos do sistema e as restrições deles | Não |
| `VARIABLES` | `Blablacar` | O estado | Sim |
| `INVARIANT` | `Blablacar` | O tipo de cada variável e as regras de segurança | Tem de valer sempre |
| `INITIALISATION` | `Blablacar` | O estado inicial (sistema vazio) | Uma vez, no começo |
| `OPERATIONS` | `Blablacar` | O que o usuário do sistema pode fazer | Cada chamada muda o estado |

## `SEES` — a máquina de sistema enxerga o contexto

```b
MACHINE Blablacar
SEES
  Blablacar_ctx
```

`Blablacar_ctx` não tem estado. Ela declara os conjuntos e as constantes. `SEES` torna esses nomes visíveis em `Blablacar` sem copiá-los: `USERS`, `max_seats` e `open` no invariante e nas pré-condições são os da máquina de contexto.

O contexto não muda quando uma operação roda. Nenhuma operação de `Blablacar` atribui valor a `min_score` ou a `max_seats`.

## `SETS` — de onde vêm os identificadores

Estão em `Blablacar_ctx.mch`:

```b
SETS
  USERS;
  TRIPS;
  LOCATIONS;
  REQUESTS;
  TRIP_STATUS = {open, full, ongoing, finished, cancelled};
  REQ_STATUS = {pending, accepted, refused, cancelled_req}
```

`USERS`, `TRIPS`, `LOCATIONS` e `REQUESTS` são conjuntos **adiados**: existem, mas a máquina abstrata não lista os elementos. No ProB eles aparecem como `USERS1`, `TRIPS1`, etc., criados sob demanda. Na implementação (entrega 2) cada um ganha um conjunto finito concreto, num `Blablacar_ctx_i`.

`TRIP_STATUS` e `REQ_STATUS` são enums: cada conjunto já nasce com exatamente esses valores. Escrever `open` ou `pending` no restante do arquivo é usar um elemento desse conjunto. `REQUESTS` e `REQ_STATUS` já estão declarados; as variáveis e operações de pedido entram na E2.

Um elemento de `USERS` ainda não é um usuário cadastrado. É só um identificador possível. Quem está cadastrado é a variável `users`, em `Blablacar`.

## `CONSTANTS` e `PROPERTIES` — números que não mudam

Também em `Blablacar_ctx.mch`:

```b
CONSTANTS
  min_score,
  max_seats
PROPERTIES
  min_score : 0..5 &
  max_seats : NAT1 &
  max_seats = 8 &
  min_score = 3
```

Constante não é variável: nenhuma operação atribui um valor novo a ela.

`PROPERTIES` diz o que se sabe sobre elas. As duas primeiras linhas são o **tipo** (`min_score` está entre 0 e 5; `max_seats` é um natural maior ou igual a 1). As duas últimas **fixam** o valor, para o ProB animar um único sistema (nota mínima 3, no máximo 8 vagas).

`min_score` já está declarado porque faz parte do domínio do usuário. A operação que consulta essa nota (pedir carona) só entra na E2.

## `VARIABLES` — o estado, sem “objetos”

B não tem struct nem classe. Cada atributo é uma variável separada, em geral uma **função** do identificador para o valor:

| Variável | Leitura |
|----------|---------|
| `users` | Conjunto dos usuários já cadastrados |
| `verified` | Para cada usuário cadastrado, `TRUE` ou `FALSE` |
| `score` | Para cada usuário cadastrado, um número de 0 a 5 |
| `trips` | Conjunto das viagens já criadas |
| `driver(t)` | Motorista da viagem `t` |
| `origin(t)`, `destination(t)` | Origem e destino |
| `seats(t)` | Quantidade de vagas |
| `price(t)` | Preço por vaga (pode ser 0) |
| `trip_status(t)` | Status da viagem |
| `occupation(t)` | Quantas vagas já estão ocupadas |

`driver(t)` parece chamada de função porque **é** uma função: a variável `driver` guarda a tabela viagem → usuário. O mesmo vale para `verified(u)`, `score(u)`, etc.

## `INVARIANT` — tipo e regras

O invariante mistura duas coisas, unidas por `&` (“e”):

1. **Tipagem** — que forma cada variável tem.
2. **Segurança** — regras do domínio que nenhuma operação pode quebrar.

### Tipagem que já está no arquivo

```b
users <: USERS
```

`users` é um subconjunto de `USERS`: só identificadores de usuário, e nem todos precisam estar cadastrados.

```b
verified : users --> BOOL
score : users --> 0..5
driver : trips --> users
```

`A --> B` é função **total**: todo elemento de `A` tem exatamente um valor em `B`.

- Todo usuário em `users` tem verificação e pontuação. Não existe usuário cadastrado “sem score”.
- Toda viagem em `trips` tem exatamente um motorista, e esse motorista está em `users`.
- `seats : trips --> 1..max_seats` diz ao mesmo tempo “toda viagem tem vagas” e “esse número está entre 1 e 8”.
- `price : trips --> NAT` permite o 0 (`NAT` é 0, 1, 2, …). `NAT1` seria 1, 2, 3, … (é o tipo de `max_seats`).

`BOOL` é o conjunto `{TRUE, FALSE}`.

### Regras de segurança que já estão no arquivo

```b
!t.(t : trips => origin(t) /= destination(t))
```

“Para todo `t`, se `t` é uma viagem existente, então origem e destino são diferentes.”

`open` e `full` não são “toda viagem está `open`”. Com o aceite, uma viagem `open` ainda tem vaga livre (`occupation(tt) < seats(tt)`), e uma viagem `full` está exatamente lotada (`occupation(tt) = seats(tt)`).

## `INITIALISATION` — sistema vazio

```b
users := {} ||
verified := {} ||
...
```

`{}` é o conjunto vazio. Uma função cujo domínio é vazio também se escreve `{}`: no início não há usuários, então não há tabela de verificação nem de pontuação.

`:=` é atribuição. `||` junta atribuições **simultâneas**: todas leem o estado antigo e escrevem juntas. Na inicialização o efeito é o mesmo de uma sequência, porque nenhuma usa o valor de outra. Em operações futuras (aceitar um pedido e, ao mesmo tempo, atualizar ocupação e status) o `||` importa: o lado direito não vê o que o lado esquerdo acabou de escrever.

## `OPERATIONS` — pré-condição e corpo

```b
register(u) =
  PRE
    u : USERS &
    u /: users
  THEN
    skip
  END
```

`PRE` é a condição para a operação estar habilitada. Se for falsa, o ProB não deixa chamar (e, no método B, chamar fora da pré-condição não é um erro tratado dentro da operação: a operação simplesmente não se aplica).

- `u : USERS` — o parâmetro é um identificador de usuário.
- `u /: users` — esse identificador ainda não foi cadastrado (`/:` é “não pertence”).

`THEN skip` significa “não altera nada”. Por isso, hoje, animar `register` não coloca `u` em `users`, e `verify_user` nunca fica habilitada: a pré-condição dela exige `u : users`. Os corpos com atribuição entram quando formos sair do esqueleto. O efeito previsto de `register` é incluir `u`, com `verified(u) = FALSE` e `score(u) = 0`.

`verify_user` exige usuário já cadastrado e ainda não verificado (`verified(u) = FALSE`).

`create_trip(t, d, o, dest, n, p)` exige, ao mesmo tempo: viagem nova, motorista cadastrado e verificado, origem e destino distintos, vagas entre 1 e `max_seats`, preço natural. `o /= dest` é o mesmo fato que o invariante de origem ≠ destino, repetido na porta de entrada da operação.

## Símbolos usados no arquivo

| Escrito | Leitura |
|---------|---------|
| `&` | e |
| `:` | pertence a / tem o tipo |
| `<:` | é subconjunto de |
| `/:` | não pertence a |
| `/=` | é diferente de |
| `-->` | função total (todo elemento do domínio tem exatamente um valor) |
| `0..5` | inteiros de 0 a 5, inclusive |
| `NAT` | 0, 1, 2, … |
| `NAT1` | 1, 2, 3, … |
| `!t.( ... )` | para todo `t`, vale … |
| `=>` | se … então … |
| `:=` | atribuição |
| `\|\|` | atribuições ao mesmo tempo |
| `{}` | conjunto vazio (ou função com domínio vazio) |
| `|->` | o par “esta chave aponta para este valor” |
| `<+` | a função da esquerda, com as chaves da direita substituídas |
| `skip` | não muda o estado |
| `PRE` / `THEN` / `END` | só executa o corpo se a condição for verdadeira |

## Atualizar uma função: `verified := verified <+ {u |-> TRUE}`

`verified` não é uma variável booleana. É a tabela inteira “usuário → está verificado?”. Para marcar uma pessoa, a operação troca essa tabela por outra, igual à anterior, em que a linha daquele usuário vale `TRUE`.

A expressão se lê de dentro para fora.

`u |-> TRUE` é um único par: a chave `u` aponta para `TRUE`. As chaves `{ }` em volta fazem disso um conjunto com um par só, ou seja, uma funçãozinha de um único elemento.

`<+` é a substituição de linhas. `verified <+ {u |-> TRUE}` significa: copie `verified` e, onde a função da direita tiver uma chave, use o valor dela. Aqui a direita só tem `u`, então todas as outras pessoas ficam como estavam e `u` passa a `TRUE`.

`:=` guarda essa tabela nova na variável `verified`. O estado antigo não é editado no meio; a variável passa a apontar para a função resultante.

Exemplo. Antes da operação, dois usuários cadastrados:

| usuário | `verified` |
|---------|------------|
| Ana | `FALSE` |
| Bruno | `TRUE` |

`verify_user(Ana)` faz `verified := verified <+ {Ana |-> TRUE}`. Depois:

| usuário | `verified` |
|---------|------------|
| Ana | `TRUE` |
| Bruno | `TRUE` |

Bruno não entra na expressão. A linha dele permanece porque `<+` só troca as chaves que aparecem à direita.

O mesmo formato serve para incluir alguém no cadastro. `{u |-> FALSE}` é a linha nova; `verified <+ {u |-> FALSE}` acrescenta essa linha porque `u` ainda não estava na tabela. Num `register(u)` futuro, as três atribuições acontecem juntas:

```b
users := users \/ {u} ||
verified := verified <+ {u |-> FALSE} ||
score := score <+ {u |-> 0}
```

`\/` é união de conjuntos: `users` passa a conter quem já estava, mais `u`.

## `IF`, `LET` e `ANY`

`accept_request` usa os três. `LET tt, others BE ... IN ... END` dá nome a dois valores calculados uma vez: a viagem do pedido e o conjunto dos outros pedidos `pending` dessa viagem. `IF ... THEN ... ELSE ... END` separa o caso em que o aceite lota a viagem do caso em que ainda sobra vaga.

`auto_accept_fitting` não recebe o pedido como parâmetro. O corpo é

```b
ANY rr WHERE
  rr : requests &
  req_status(rr) = pending &
  occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr))
THEN
  /* o mesmo efeito de accept_request */
END
```

`ANY` escolhe um `rr` que satisfaz o `WHERE`. Se houver mais de um, a escolha não é fixa: o ProB pode animar qualquer um deles. Se não houver nenhum, a operação não fica habilitada.

`!r1.(...)` (“para todo”) e `!(r1, r2).(...)` aparecem no invariante e nas pré-condições, por exemplo para impedir dois pedidos ativos do mesmo passageiro na mesma viagem. `#rr.(...)` (“existe”) é a pré-condição de `auto_accept_fitting`: a operação só vale se existir pelo menos um pedido que caiba.

## Pré-imagem e sobrescrita em lote

`req_trip~[{tt}]` é a pré-imagem: os pedidos cuja viagem é `tt`. `req_status~[{pending}]` são os pedidos que hoje estão `pending`. A interseção dos dois, menos o pedido que está sendo aceito, é o conjunto `others`.

`others * {refused}` é o produto cartesiano: uma tabela em que cada pedido de `others` aponta para `refused`. No aceite que lota, essa tabela entra no `<+` e troca todas essas linhas de uma vez:

```b
req_status := (req_status <+ {rr |-> accepted}) <+ (others * {refused})
```

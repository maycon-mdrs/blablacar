MACHINE Blablacar                                          /* copia de leitura; o arquivo que vale e Blablacar.mch */
SEES                                                       /* SEES torna visiveis os SETS e as CONSTANTS da maquina citada. Esta maquina enxerga a de contexto */
  Blablacar_ctx                                            /* maquina vista: USERS, TRIPS, LOCATIONS, TRIP_STATUS e max_seats. De la vem os identificadores e as constantes */
VARIABLES                                                  /* nomes do estado; o tipo de cada um esta no INVARIANT. Daqui para baixo e o que muda */
  users,                                                   /* conjunto; no invariante, subconjunto de USERS. Usuarios ja cadastrados */
  verified,                                                /* funcao; no invariante, total de users em BOOL. Usuario cadastrado -> TRUE ou FALSE */
  score,                                                   /* funcao; no invariante, total de users em 0..5. Usuario cadastrado -> nota de 0 a 5 */
  trips,                                                   /* conjunto; no invariante, subconjunto de TRIPS. Viagens ja criadas */
  driver,                                                  /* funcao; no invariante, total de trips em users. Viagem -> motorista */
  origin,                                                  /* funcao; no invariante, total de trips em LOCATIONS. Viagem -> local de origem */
  destination,                                             /* funcao; no invariante, total de trips em LOCATIONS. Viagem -> local de destino */
  seats,                                                   /* funcao; no invariante, total de trips em 1..max_seats. Viagem -> quantidade de vagas */
  price,                                                   /* funcao; no invariante, total de trips em NAT. Viagem -> preco por vaga (0 e permitido) */
  trip_status,                                             /* funcao; no invariante, total de trips em TRIP_STATUS. Viagem -> open, full, ongoing, finished ou cancelled */
  occupation                                               /* funcao; no invariante, total de trips em NAT. Viagem -> vagas ja reservadas */
INVARIANT                                                  /* predicado que vale no inicio e depois de cada operacao. Tudo abaixo tem de continuar verdade */
  users <: USERS &                                         /* users e subconjunto de USERS. <: = subconjunto; & = e logico. Users so contem identificadores de usuario */
  verified : users --> BOOL &                              /* verified pertence ao conjunto das funcoes totais de users em BOOL. : = pertence; --> = funcao total; BOOL = {TRUE, FALSE}. Todo cadastrado tem exatamente um TRUE ou FALSE */
  score : users --> 0..5 &                                 /* score e funcao total de users no intervalo 0..5. .. = intervalo fechado. Todo cadastrado tem exatamente uma nota de 0 a 5 */
  trips <: TRIPS &                                         /* trips e subconjunto de TRIPS. Trips so contem identificadores de viagem */
  driver : trips --> users &                               /* driver e funcao total de trips em users. Toda viagem tem um motorista cadastrado */
  origin : trips --> LOCATIONS &                           /* origin e funcao total de trips em LOCATIONS. Toda viagem tem uma origem */
  destination : trips --> LOCATIONS &                      /* destination e funcao total de trips em LOCATIONS. Toda viagem tem um destino */
  seats : trips --> 1..max_seats &                         /* seats e funcao total de trips no intervalo 1..max_seats. Vagas entre 1 e 8 */
  price : trips --> NAT &                                  /* price e funcao total de trips em NAT. NAT = {0, 1, 2, ...}. Preco natural, incluindo 0 */
  trip_status : trips --> TRIP_STATUS &                    /* trip_status e funcao total de trips em TRIP_STATUS. Toda viagem tem um status */
  occupation : trips --> NAT &                             /* occupation e funcao total de trips em NAT. Toda viagem tem um contador de ocupacao */
  !tt.(tt : trips => origin(tt) /= destination(tt)) &      /* ! = para todo. Se tt pertence a trips, entao origin(tt) e diferente de destination(tt). => = implica; /= = diferente. Para toda viagem, origem e destino sao diferentes */
  !tt.(tt : trips => trip_status(tt) = open)               /* se tt pertence a trips, entao a imagem trip_status(tt) e open. Para toda viagem existente, o status e open */
INITIALISATION                                             /* atribuicoes do estado inicial. := atribui; || avalia os lados direitos no estado anterior e aplica juntos. Sistema vazio */
  users := {} ||                                           /* users recebe o conjunto vazio. {} = conjunto vazio. Nenhum usuario */
  verified := {} ||                                        /* verified recebe {}, a funcao sem pares. Tabela de verificacao vazia */
  score := {} ||                                           /* score recebe {}. Tabela de notas vazia */
  trips := {} ||                                           /* trips recebe {}. Nenhuma viagem */
  driver := {} ||                                          /* driver recebe {}. Sem motoristas gravados */
  origin := {} ||                                          /* origin recebe {}. Sem origens */
  destination := {} ||                                     /* destination recebe {}. Sem destinos */
  seats := {} ||                                           /* seats recebe {}. Sem vagas */
  price := {} ||                                           /* price recebe {}. Sem precos */
  trip_status := {} ||                                     /* trip_status recebe {}. Sem status de viagem */
  occupation := {}                                         /* occupation recebe {}. Sem ocupacao */
OPERATIONS                                                 /* operacoes sobre o estado; cada uma so ocorre se o PRE for verdadeiro */
  register(uu) =                                           /* define a operacao register; uu e parametro de entrada. Cadastra o usuario uu */
    PRE                                                    /* predicado de habilitacao: a operacao so ocorre se ele for verdadeiro */
      uu : USERS &                                         /* uu pertence a USERS. uu e um identificador de usuario possivel */
      uu /: users                                          /* uu nao pertence a users. /: = nao pertence. uu ainda nao esta cadastrado */
    THEN                                                   /* substituicao executada quando o PRE vale */
      users := users \/ {uu} ||                            /* users recebe a uniao de users com o conjunto unitario {uu}. \/ = uniao. Inclui uu */
      verified := verified <+ {uu |-> FALSE} ||            /* <+ sobrescreve a funcao com esse par: acrescenta ou troca a imagem de uu. |-> forma o par. Acrescenta a linha uu -> FALSE */
      score := score <+ {uu |-> 0}                         /* sobrescreve score com o par uu |-> 0. Nota inicial 0 */
    END;

  verify_user(uu) =                                        /* define a operacao verify_user; uu e parametro de entrada. Marca uu como verificado */
    PRE
      uu : USERS &                                         /* uu pertence a USERS. uu e um identificador de usuario */
      uu : users &                                         /* uu pertence a users. uu ja esta cadastrado */
      verified(uu) = FALSE                                 /* a imagem de uu pela funcao verified e FALSE. A linha de uu ainda vale FALSE */
    THEN
      verified := verified <+ {uu |-> TRUE}                /* sobrescreve verified com o par uu |-> TRUE. Troca so a linha de uu para TRUE */
    END;

  create_trip(tt, dd, oo, dest, nn, pp) =                  /* define a operacao; tt, dd, oo, dest, nn e pp sao parametros de entrada. Cria a viagem tt: dd motorista, oo origem, dest destino, nn vagas, pp preco */
    PRE
      tt : TRIPS &                                         /* tt pertence a TRIPS. tt e um identificador de viagem possivel */
      tt /: trips &                                        /* tt nao pertence a trips. Essa viagem ainda nao existe */
      dd : USERS &                                         /* dd pertence a USERS. dd e um identificador de usuario */
      dd : users &                                         /* dd pertence a users. O motorista ja esta cadastrado */
      verified(dd) = TRUE &                                /* a imagem de dd por verified e TRUE. O motorista esta verificado */
      oo : LOCATIONS &                                     /* oo pertence a LOCATIONS. Origem e um local */
      dest : LOCATIONS &                                   /* dest pertence a LOCATIONS. Destino e um local */
      oo /= dest &                                         /* oo e diferente de dest. Origem e destino sao diferentes */
      nn : 1..max_seats &                                  /* nn pertence ao intervalo 1..max_seats. Vagas entre 1 e 8 */
      pp : NAT                                             /* pp pertence a NAT. Preco natural, incluindo 0 */
    THEN
      trips := trips \/ {tt} ||                            /* trips recebe trips unido ao unitario {tt}. Inclui tt no conjunto de viagens */
      driver := driver <+ {tt |-> dd} ||                   /* sobrescreve driver com o par tt |-> dd. Grava o motorista */
      origin := origin <+ {tt |-> oo} ||                   /* sobrescreve origin com o par tt |-> oo. Grava a origem */
      destination := destination <+ {tt |-> dest} ||       /* sobrescreve destination com o par tt |-> dest. Grava o destino */
      seats := seats <+ {tt |-> nn} ||                     /* sobrescreve seats com o par tt |-> nn. Grava a quantidade de vagas */
      price := price <+ {tt |-> pp} ||                     /* sobrescreve price com o par tt |-> pp. Grava o preco */
      trip_status := %xx.(xx : trips \/ {tt} | open) ||    /* %xx.(xx : S | E) e a funcao que manda cada xx de S para E. S e trips \/ {tt} e E e open, entao trip_status inteira passa a valer open. O trips a direita ainda e o valor anterior ao ||. Toda viagem existente, inclusive a nova, fica open */
      occupation := occupation <+ {tt |-> 0}               /* sobrescreve occupation com o par tt |-> 0. Nenhuma vaga reservada ainda */
    END
END

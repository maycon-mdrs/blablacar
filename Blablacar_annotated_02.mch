MACHINE Blablacar                                          /* copia de leitura; o arquivo que vale e Blablacar_02.mch */
SEES                                                       /* esta maquina enxerga a de contexto */
  Blablacar_ctx                                            /* de la vem USERS, TRIPS, open, pending, min_score, max_seats */
VARIABLES                                                  /* daqui para baixo e o estado, o que muda */
  users,                                                   /* usuarios ja cadastrados */
  verified,                                                /* usuario cadastrado -> TRUE ou FALSE */
  score,                                                   /* usuario cadastrado -> nota de 0 a 5 */
  trips,                                                   /* viagens ja criadas */
  driver,                                                  /* viagem -> motorista */
  origin,                                                  /* viagem -> local de origem */
  destination,                                             /* viagem -> local de destino */
  seats,                                                   /* viagem -> quantidade de vagas */
  price,                                                   /* viagem -> preco por vaga (0 e permitido) */
  trip_status,                                             /* viagem -> open, full, ongoing, finished ou cancelled */
  occupation,                                              /* viagem -> vagas ja reservadas */
  requests,                                                /* pedidos ja criados */
  req_trip,                                                /* pedido -> viagem */
  req_passenger,                                           /* pedido -> passageiro */
  req_seats,                                               /* pedido -> quantas vagas pede */
  req_status                                               /* pedido -> pending, accepted, refused ou cancelled_req */
INVARIANT                                                  /* tudo abaixo tem de continuar verdade */
  users <: USERS &                                         /* users so contem identificadores de usuario */
  verified : users --> BOOL &                              /* todo cadastrado tem exatamente um TRUE ou FALSE */
  score : users --> 0..5 &                                 /* todo cadastrado tem exatamente uma nota de 0 a 5 */
  trips <: TRIPS &                                         /* trips so contem identificadores de viagem */
  driver : trips --> users &                               /* toda viagem tem um motorista cadastrado */
  origin : trips --> LOCATIONS &                           /* toda viagem tem uma origem */
  destination : trips --> LOCATIONS &                      /* toda viagem tem um destino */
  seats : trips --> 1..max_seats &                         /* vagas entre 1 e 8 */
  price : trips --> NAT &                                  /* preco natural, incluindo 0 */
  trip_status : trips --> TRIP_STATUS &                    /* toda viagem tem um status */
  occupation : trips --> NAT &                             /* toda viagem tem um contador de ocupacao */
  requests <: REQUESTS &                                   /* requests so contem identificadores de pedido */
  req_trip : requests --> trips &                          /* todo pedido aponta para uma viagem existente */
  req_passenger : requests --> users &                     /* todo pedido aponta para um usuario cadastrado */
  req_seats : requests --> NAT1 &                          /* todo pedido pede pelo menos 1 vaga */
  req_status : requests --> REQ_STATUS &                   /* todo pedido tem um status */
  !tt.(tt : trips => origin(tt) /= destination(tt)) &      /* para toda viagem, origem e destino sao diferentes */
  !rr.(rr : requests => req_passenger(rr) /= driver(req_trip(rr))) &  /* passageiro nunca e o motorista daquela viagem */
  !rr.(rr : requests => req_seats(rr) <= seats(req_trip(rr))) &  /* vagas pedidas nao passam da capacidade */
  !tt.(tt : trips => occupation(tt) <= seats(tt)) &        /* ocupacao nunca passa do numero de vagas */
  !tt.(tt : trips & trip_status(tt) = open => occupation(tt) < seats(tt)) &  /* open significa que ainda sobra vaga */
  !tt.(tt : trips & trip_status(tt) = full => occupation(tt) = seats(tt)) &  /* full significa ocupacao igual a capacidade */
  !(r1, r2).(r1 : requests & r2 : requests &               /* para todo par de pedidos r1 e r2 */
             req_status(r1) : {pending, accepted} &        /* se r1 esta ativo */
             req_status(r2) : {pending, accepted} &        /* e r2 tambem esta ativo */
             req_passenger(r1) = req_passenger(r2) &       /* e sao o mesmo passageiro */
             req_trip(r1) = req_trip(r2)                   /* na mesma viagem */
             => r1 = r2)                                   /* entao e o mesmo pedido; nao ha dois ativos iguais */
INITIALISATION                                             /* estado inicial: sistema vazio. := atribui; || e ao mesmo tempo */
  users := {} ||                                           /* nenhum usuario. {} e o conjunto vazio */
  verified := {} ||                                        /* tabela de verificacao vazia */
  score := {} ||                                           /* tabela de notas vazia */
  trips := {} ||                                           /* nenhuma viagem */
  driver := {} ||                                          /* sem motoristas gravados */
  origin := {} ||                                          /* sem origens */
  destination := {} ||                                     /* sem destinos */
  seats := {} ||                                           /* sem vagas */
  price := {} ||                                           /* sem precos */
  trip_status := {} ||                                     /* sem status de viagem */
  occupation := {} ||                                      /* sem ocupacao */
  requests := {} ||                                        /* nenhum pedido */
  req_trip := {} ||                                        /* sem ligacao pedido-viagem */
  req_passenger := {} ||                                   /* sem ligacao pedido-passageiro */
  req_seats := {} ||                                       /* sem quantidade pedida */
  req_status := {}                                         /* sem status de pedido */
OPERATIONS                                                 /* cada operacao so roda se o PRE for verdadeiro */
  register(uu) =                                           /* cadastra o usuario uu */
    PRE
      uu : USERS &                                         /* uu e um identificador de usuario possivel */
      uu /: users                                          /* uu ainda nao esta cadastrado. /: = nao pertence */
    THEN
      users := users \/ {uu} ||                            /* inclui uu. \/ e uniao de conjuntos */
      verified := verified <+ {uu |-> FALSE} ||            /* acrescenta a linha uu -> FALSE. <+ so mexe nessa chave */
      score := score <+ {uu |-> 0}                         /* nota inicial 0 */
    END;

  verify_user(uu) =                                        /* marca uu como verificado */
    PRE
      uu : USERS &                                         /* uu e um identificador de usuario */
      uu : users &                                         /* uu ja esta cadastrado */
      verified(uu) = FALSE                                 /* a linha de uu ainda vale FALSE */
    THEN
      verified := verified <+ {uu |-> TRUE}                /* troca so a linha de uu para TRUE */
    END;

  create_trip(tt, dd, oo, dest, nn, pp) =                  /* cria a viagem tt. dd motorista, oo origem, nn vagas, pp preco */
    PRE
      tt : TRIPS &                                         /* tt e um identificador de viagem possivel */
      tt /: trips &                                        /* essa viagem ainda nao existe */
      dd : USERS &                                         /* dd e um identificador de usuario */
      dd : users &                                         /* o motorista ja esta cadastrado */
      verified(dd) = TRUE &                                /* o motorista esta verificado */
      oo : LOCATIONS &                                     /* origem e um local */
      dest : LOCATIONS &                                   /* destino e um local */
      oo /= dest &                                         /* origem e destino sao diferentes */
      nn : 1..max_seats &                                  /* vagas entre 1 e 8 */
      pp : NAT                                             /* preco natural, incluindo 0 */
    THEN
      trips := trips \/ {tt} ||                            /* inclui tt no conjunto de viagens */
      driver := driver <+ {tt |-> dd} ||                   /* grava o motorista */
      origin := origin <+ {tt |-> oo} ||                   /* grava a origem */
      destination := destination <+ {tt |-> dest} ||       /* grava o destino */
      seats := seats <+ {tt |-> nn} ||                     /* grava a quantidade de vagas */
      price := price <+ {tt |-> pp} ||                     /* grava o preco */
      trip_status := trip_status <+ {tt |-> open} ||       /* so esta viagem nasce open */
      occupation := occupation <+ {tt |-> 0}               /* nenhuma vaga reservada ainda */
    END;

  request_ride(rr, tt, uu, nn) =                           /* uu pede nn vagas na viagem tt; o pedido se chama rr */
    PRE
      rr : REQUESTS &                                      /* rr e um identificador de pedido possivel */
      rr /: requests &                                     /* esse pedido ainda nao existe */
      tt : trips &                                         /* a viagem existe */
      trip_status(tt) = open &                             /* a viagem ainda aceita pedido */
      uu : users &                                         /* o passageiro esta cadastrado */
      verified(uu) = TRUE &                                /* o passageiro esta verificado */
      score(uu) >= min_score &                             /* a nota e pelo menos 3 */
      uu /= driver(tt) &                                   /* o passageiro nao e o motorista */
      nn : NAT1 &                                          /* pede pelo menos 1 vaga */
      nn <= seats(tt) &                                    /* a quantidade nao passa da capacidade */
      occupation(tt) < seats(tt) &                         /* ainda ha pelo menos 1 vaga livre */
      !r1.(r1 : requests &                                 /* para todo pedido r1 que ja existe */
            req_trip(r1) = tt &                            /* se for nesta viagem */
            req_passenger(r1) = uu                         /* e deste passageiro */
            => req_status(r1) /: {pending, accepted})      /* ele nao pode estar pending nem accepted */
    THEN
      requests := requests \/ {rr} ||                      /* inclui o pedido novo */
      req_trip := req_trip <+ {rr |-> tt} ||               /* liga o pedido a viagem */
      req_passenger := req_passenger <+ {rr |-> uu} ||     /* liga o pedido ao passageiro */
      req_seats := req_seats <+ {rr |-> nn} ||             /* grava quantas vagas foram pedidas */
      req_status := req_status <+ {rr |-> pending}         /* o pedido nasce esperando resposta */
    END;

  accept_request(rr) =                                     /* aceita rr e reserva todas as vagas dele de uma vez */
    PRE
      rr : requests &                                      /* o pedido existe */
      req_status(rr) = pending &                           /* ele ainda esta esperando resposta */
      occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr))  /* as vagas pedidas cabem no que resta */
    THEN
      LET tt, others BE                                    /* da nome a dois valores para nao repetir a conta */
        tt = req_trip(rr) &                                /* tt passa a ser a viagem deste pedido */
        others = (req_trip~[{req_trip(rr)}] /\ req_status~[{pending}]) - {rr}  /* outros pending desta viagem, sem o rr */
      IN                                                     /* ~[conjunto] e a pre-imagem; /\ e intersecao; - tira rr */
        IF occupation(tt) + req_seats(rr) = seats(tt) THEN /* este aceite lota a viagem exatamente */
          occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||  /* soma as vagas no contador */
          trip_status := trip_status <+ {tt |-> full} ||   /* a viagem passa a full */
          req_status := (req_status <+ {rr |-> accepted}) <+ (others * {refused})  /* rr accepted; others * {refused} recusa o resto */
        ELSE                                               /* ainda sobra vaga */
          occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||  /* soma as vagas; status continua open */
          req_status := req_status <+ {rr |-> accepted}    /* so este pedido fica accepted */
        END
      END
    END;

  refuse_request(rr) =                                     /* recusa rr; nao mexe na ocupacao */
    PRE
      rr : requests &                                      /* o pedido existe */
      req_status(rr) = pending                             /* ele ainda esta esperando resposta */
    THEN
      req_status := req_status <+ {rr |-> refused}         /* troca so a linha desse pedido para refused */
    END;

  auto_accept_fitting =                                    /* sem parametro: escolhe sozinho um pending que caiba */
    PRE
      #rr.(rr : requests &                                 /* existe pelo menos um pedido. # significa existe */
           req_status(rr) = pending &                      /* que esta pending */
           occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr)))  /* e cujas vagas ainda cabem */
    THEN
      ANY rr WHERE                                         /* escolhe um rr; se houver varios, qualquer um serve */
        rr : requests &                                    /* o escolhido tem de ser um pedido que existe */
        req_status(rr) = pending &                         /* e tem de estar esperando resposta */
        occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr))  /* e as vagas dele ainda cabem */
      THEN
        LET tt, others BE                                  /* da nome a dois valores para nao repetir a conta */
          tt = req_trip(rr) &                              /* tt passa a ser a viagem do pedido escolhido */
          others = (req_trip~[{req_trip(rr)}] /\ req_status~[{pending}]) - {rr}  /* outros pending dessa viagem, sem o rr */
        IN                                                 /* ~[conjunto] e a pre-imagem; /\ e intersecao; - tira rr */
          IF occupation(tt) + req_seats(rr) = seats(tt) THEN  /* este aceite lota a viagem exatamente */
            occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||  /* soma as vagas do pedido escolhido no contador */
            trip_status := trip_status <+ {tt |-> full} || /* a viagem passa a full */
            req_status := (req_status <+ {rr |-> accepted}) <+ (others * {refused})  /* rr fica accepted; others * {refused} recusa o resto de uma vez */
          ELSE                                             /* ainda sobra vaga depois deste aceite */
            occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||  /* soma as vagas; o status da viagem continua open */
            req_status := req_status <+ {rr |-> accepted}  /* so o pedido escolhido fica accepted */
          END
        END
      END
    END
END

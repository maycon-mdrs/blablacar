MACHINE Blablacar
SEES
  Blablacar_ctx
VARIABLES
  users,
  verified,
  score,
  trips,
  driver,
  origin,
  destination,
  seats,
  price,
  trip_status,
  occupation,
  requests,
  req_trip,
  req_passenger,
  req_seats,
  req_status
INVARIANT
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
  requests <: REQUESTS &
  req_trip : requests --> trips &
  req_passenger : requests --> users &
  req_seats : requests --> NAT1 &
  req_status : requests --> REQ_STATUS &
  !tt.(tt : trips => origin(tt) /= destination(tt)) &
  !rr.(rr : requests => req_passenger(rr) /= driver(req_trip(rr))) &
  !rr.(rr : requests => req_seats(rr) <= seats(req_trip(rr))) &
  !tt.(tt : trips => occupation(tt) <= seats(tt)) &
  !tt.(tt : trips & trip_status(tt) = open => occupation(tt) < seats(tt)) &
  !tt.(tt : trips & trip_status(tt) = full => occupation(tt) = seats(tt)) &
  !(r1, r2).(r1 : requests & r2 : requests &
             req_status(r1) : {pending, accepted} &
             req_status(r2) : {pending, accepted} &
             req_passenger(r1) = req_passenger(r2) &
             req_trip(r1) = req_trip(r2)
             => r1 = r2)
INITIALISATION
  users := {} ||
  verified := {} ||
  score := {} ||
  trips := {} ||
  driver := {} ||
  origin := {} ||
  destination := {} ||
  seats := {} ||
  price := {} ||
  trip_status := {} ||
  occupation := {} ||
  requests := {} ||
  req_trip := {} ||
  req_passenger := {} ||
  req_seats := {} ||
  req_status := {}
OPERATIONS
  register(uu) =
    PRE
      uu : USERS &
      uu /: users
    THEN
      users := users \/ {uu} ||
      verified := verified <+ {uu |-> FALSE} ||
      score := score <+ {uu |-> 0}
    END;

  verify_user(uu) =
    PRE
      uu : USERS &
      uu : users &
      verified(uu) = FALSE
    THEN
      verified := verified <+ {uu |-> TRUE}
    END;

  create_trip(tt, dd, oo, dest, nn, pp) =
    PRE
      tt : TRIPS &
      tt /: trips &
      dd : USERS &
      dd : users &
      verified(dd) = TRUE &
      oo : LOCATIONS &
      dest : LOCATIONS &
      oo /= dest &
      nn : 1..max_seats &
      pp : NAT
    THEN
      trips := trips \/ {tt} ||
      driver := driver <+ {tt |-> dd} ||
      origin := origin <+ {tt |-> oo} ||
      destination := destination <+ {tt |-> dest} ||
      seats := seats <+ {tt |-> nn} ||
      price := price <+ {tt |-> pp} ||
      trip_status := trip_status <+ {tt |-> open} ||
      occupation := occupation <+ {tt |-> 0}
    END;

  request_ride(rr, tt, uu, nn) =
    PRE
      rr : REQUESTS &
      rr /: requests &
      tt : trips &
      trip_status(tt) = open &
      uu : users &
      verified(uu) = TRUE &
      score(uu) >= min_score &
      uu /= driver(tt) &
      nn : NAT1 &
      nn <= seats(tt) &
      occupation(tt) < seats(tt) &
      !r1.(r1 : requests &
            req_trip(r1) = tt &
            req_passenger(r1) = uu
            => req_status(r1) /: {pending, accepted})
    THEN
      requests := requests \/ {rr} ||
      req_trip := req_trip <+ {rr |-> tt} ||
      req_passenger := req_passenger <+ {rr |-> uu} ||
      req_seats := req_seats <+ {rr |-> nn} ||
      req_status := req_status <+ {rr |-> pending}
    END;

  accept_request(rr) =
    PRE
      rr : requests &
      req_status(rr) = pending &
      occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr))
    THEN
      LET tt, others BE
        tt = req_trip(rr) &
        others = (req_trip~[{req_trip(rr)}] /\ req_status~[{pending}]) - {rr}
      IN
        IF occupation(tt) + req_seats(rr) = seats(tt) THEN
          occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||
          trip_status := trip_status <+ {tt |-> full} ||
          req_status := (req_status <+ {rr |-> accepted}) <+ (others * {refused})
        ELSE
          occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||
          req_status := req_status <+ {rr |-> accepted}
        END
      END
    END;

  refuse_request(rr) =
    PRE
      rr : requests &
      req_status(rr) = pending
    THEN
      req_status := req_status <+ {rr |-> refused}
    END;

  auto_accept_fitting =
    PRE
      #rr.(rr : requests &
           req_status(rr) = pending &
           occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr)))
    THEN
      ANY rr WHERE
        rr : requests &
        req_status(rr) = pending &
        occupation(req_trip(rr)) + req_seats(rr) <= seats(req_trip(rr))
      THEN
        LET tt, others BE
          tt = req_trip(rr) &
          others = (req_trip~[{req_trip(rr)}] /\ req_status~[{pending}]) - {rr}
        IN
          IF occupation(tt) + req_seats(rr) = seats(tt) THEN
            occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||
            trip_status := trip_status <+ {tt |-> full} ||
            req_status := (req_status <+ {rr |-> accepted}) <+ (others * {refused})
          ELSE
            occupation := occupation <+ {tt |-> occupation(tt) + req_seats(rr)} ||
            req_status := req_status <+ {rr |-> accepted}
          END
        END
      END
    END
END

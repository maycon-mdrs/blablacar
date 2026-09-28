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
  occupation
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
  !tt.(tt : trips => origin(tt) /= destination(tt)) &
  !tt.(tt : trips => trip_status(tt) = open)
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
  occupation := {}
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
      trip_status := %xx.(xx : trips \/ {tt} | open) ||
      occupation := occupation <+ {tt |-> 0}
    END
END

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
  !t.(t : trips => origin(t) /= destination(t)) &
  !t.(t : trips => trip_status(t) = open)
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
  register(u) =
    PRE
      u : USERS &
      u /: users
    THEN
      users := users \/ {u} ||
      verified := verified <+ {u |-> FALSE} ||
      score := score <+ {u |-> 0}
    END;

  verify_user(u) =
    PRE
      u : users &
      verified(u) = FALSE
    THEN
      verified := verified <+ {u |-> TRUE}
    END;

  create_trip(t, d, o, dest, n, p) =
    PRE
      t : TRIPS &
      t /: trips &
      d : users &
      verified(d) = TRUE &
      o : LOCATIONS &
      dest : LOCATIONS &
      o /= dest &
      n : 1..max_seats &
      p : NAT
    THEN
      trips := trips \/ {t} ||
      driver := driver <+ {t |-> d} ||
      origin := origin <+ {t |-> o} ||
      destination := destination <+ {t |-> dest} ||
      seats := seats <+ {t |-> n} ||
      price := price <+ {t |-> p} ||
      trip_status := trip_status <+ {t |-> open} ||
      occupation := occupation <+ {t |-> 0}
    END
END

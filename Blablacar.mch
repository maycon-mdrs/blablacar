MACHINE Blablacar
SETS
  USERS;
  TRIPS;
  LOCATIONS;
  TRIP_STATUS = {draft, open, full, ongoing, finished, cancelled}
CONSTANTS
  min_score,
  max_seats
PROPERTIES
  min_score : 0..5 &
  max_seats : NAT1 &
  max_seats = 8 &
  min_score = 3
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
  !t.(t : trips & trip_status(t) = draft => occupation(t) = 0) &
  !t.(t : trips => trip_status(t) : {draft, open})
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
      skip
    END;

  verify_user(u) =
    PRE
      u : users &
      verified(u) = FALSE
    THEN
      skip
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
      skip
    END;

  publish_trip(t) =
    PRE
      t : trips &
      trip_status(t) = draft
    THEN
      skip
    END
END

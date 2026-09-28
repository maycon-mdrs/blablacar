MACHINE
  Blablacar_ctx
SETS
  USERS;
  TRIPS;
  LOCATIONS;
  REQUESTS;
  TRIP_STATUS = {open, full, ongoing, finished, cancelled};
  REQ_STATUS = {pending, accepted, refused, cancelled_req}
CONSTANTS
  min_score,
  max_seats
PROPERTIES
  min_score : 0..5 &
  max_seats : NAT1 &
  max_seats = 8 &
  min_score = 3
END

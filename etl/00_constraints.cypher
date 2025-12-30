//constraints
// Airport
CREATE CONSTRAINT airport_id_unique
IF NOT EXISTS
FOR (a:Airport)
REQUIRE a.airportId IS UNIQUE;

CREATE CONSTRAINT airport_lat_exists
IF NOT EXISTS
FOR (a:Airport)
REQUIRE a.lat IS NOT NULL;

CREATE CONSTRAINT airport_lon_exists
IF NOT EXISTS
FOR (a:Airport)
REQUIRE a.lon IS NOT NULL;

// Route
CREATE CONSTRAINT route_distance_exists
IF NOT EXISTS
FOR ()-[r:ROUTE]-()
REQUIRE r.distance_km IS NOT NULL;

CREATE CONSTRAINT route_airlineId_exists
IF NOT EXISTS
FOR ()-[r:ROUTE]-()
REQUIRE r.airlineId IS NOT NULL;

CREATE CONSTRAINT route_stops_exists
IF NOT EXISTS
FOR ()-[r:ROUTE]-()
REQUIRE r.stops IS NOT NULL;

// Country
CREATE CONSTRAINT country_iso_unique
IF NOT EXISTS
FOR (c:Country)
REQUIRE c.iso IS UNIQUE;

// Airline
CREATE CONSTRAINT airline_id_unique
IF NOT EXISTS
FOR (al:Airline)
REQUIRE al.airlineId IS UNIQUE;

// Alliance
CREATE CONSTRAINT alliance_name_unique
IF NOT EXISTS
FOR (al:Alliance)
REQUIRE al.name IS UNIQUE;


CREATE INDEX airport_iata IF NOT EXISTS FOR (a:Airport) ON (a.iata);
CREATE INDEX airport_icao IF NOT EXISTS FOR (a:Airport) ON (a.icao);
CREATE INDEX airline_iata IF NOT EXISTS FOR (al:Airline) ON (al.iata);
CREATE INDEX airline_icao IF NOT EXISTS FOR (al:Airline) ON (al.icao);
CREATE INDEX country_name IF NOT EXISTS FOR (c:Country) ON (c.name);

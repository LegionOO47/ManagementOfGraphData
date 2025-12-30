//constraints
// Airport
CREATE CONSTRAINT airport_id_unique
FOR (a:Airport)
REQUIRE a.airportId IS UNIQUE;

// Country
CREATE CONSTRAINT country_iso_unique
FOR (c:Country)
REQUIRE c.iso IS UNIQUE;

// Airline
CREATE CONSTRAINT airline_id_unique
FOR (al:Airline)
REQUIRE al.airlineId IS UNIQUE;

// Alliance
CREATE CONSTRAINT alliance_name_unique
FOR (al:Alliance)
REQUIRE al.name IS UNIQUE;


CREATE INDEX airport_iata FOR (a:Airport) ON (a.iata);
CREATE INDEX airport_icao FOR (a:Airport) ON (a.icao);
CREATE INDEX airline_iata FOR (al:Airline) ON (al.iata);
CREATE INDEX airline_icao FOR (al:Airline) ON (al.icao);
CREATE INDEX country_name FOR (c:Country) ON (c.name);

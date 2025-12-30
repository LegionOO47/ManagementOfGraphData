:param {
  file_path_root: 'file:///', // Folder your files are accessible at
  file_0: 'airport.csv',
  file_1: 'airlines.csv',
  file_2: 'countries.csv',
  file_3: 'routes.csv',
  idsToSkip: []
};

// CONSTRAINT creation
CREATE CONSTRAINT airportId_Airport_uniq IF NOT EXISTS
FOR (n:Airport)
REQUIRE n.airportId IS UNIQUE;

CREATE CONSTRAINT airlineId_Airline_uniq IF NOT EXISTS
FOR (n:Airline)
REQUIRE n.airlineId IS UNIQUE;

CREATE CONSTRAINT iso_Country_uniq IF NOT EXISTS
FOR (n:Country)
REQUIRE n.iso IS UNIQUE;

//////////////////////////
// LOAD AIRPORT NODES
//////////////////////////
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`Airport ID` IN $idsToSkip AND row.`Airport ID` IS NOT NULL
MERGE (a:Airport {airportId: toInteger(trim(row.`Airport ID`))})
SET a.iata = row.IATA,
    a.icao = row.ICAO,
    a.airportName = row.Name,
    a.city = row.City,
    a.countryName = row.Country,
    a.lat = toFloat(trim(row.Latitude)),
    a.lon = toFloat(trim(row.Longitude));

//////////////////////////
// LOAD AIRLINE NODES
//////////////////////////
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`Airline ID` IN $idsToSkip AND row.`Airline ID` IS NOT NULL
MERGE (a:Airline {airlineId: toInteger(trim(row.`Airline ID`))})
SET a.name = row.Name,
    a.iata = row.IATA,
    a.icao = row.ICAO,
    a.active = row.Active;

//////////////////////////
// LOAD COUNTRY NODES
//////////////////////////
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.iso_code IN $idsToSkip AND row.iso_code IS NOT NULL
MERGE (c:Country {iso: row.iso_code})
SET c.name = row.name;

//////////////////////////
// LOAD ROUTE RELATIONSHIPS
//////////////////////////
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row
WHERE row.`Source airport ID` IS NOT NULL AND row.`Destination airport ID` IS NOT NULL
MATCH (source:Airport {airportId: toInteger(trim(row.`Source airport ID`))})
MATCH (target:Airport {airportId: toInteger(trim(row.`Destination airport ID`))})
MERGE (source)-[r:ROUTE]->(target)
SET r.airlinecode = row.Airline,
    r.airlineId = toInteger(trim(row.`Airline ID`)),
    r.codeShare = row.Codeshare,
    r.stops = toLower(trim(row.Stops)) IN ['1','true','yes'],
    r.equipment = row.Equipment,
    r.distance_km = toFloat(trim(row.distance));


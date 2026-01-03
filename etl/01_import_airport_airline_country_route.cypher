:param {
  file_path_root: 'file:///', // Folder your files are accessible at
  file_0: 'airport.csv',
  file_1: 'airlines.csv',
  file_2: 'countries.csv',
  file_3: 'routes.csv',
  idsToSkip: []
};

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

// Because REQUIRE IS NOT NULL as a constraint is only possible on the enterprise license, this is manually enforcing this constraint.
// It is technically not necessary because nothing in the dataset fails these constraints at the current moment but this futureproves the import.
MATCH (a:Airport)
WHERE a.lat IS NULL
OR a.lon IS NULL
OR a.airportId IS NULL
DETACH DELETE a;


//Some of the Airports have their latitude and longitude stored incorrectly in the dataset. i.e 46625 rather than 46.625
//This adjusts them to the correct scale.
MATCH (a:Airport)
WHERE
  a.lat IS NOT NULL AND a.lon IS NOT NULL AND
  (abs(a.lat) > 90 OR abs(a.lon) > 180)
SET
  a.lat = a.lat / 1000.0,
  a.lon = a.lon / 1000.0;


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

MATCH ()-[r:ROUTE]-()
WHERE r.distance_km IS NULL
OR r.airlineId IS NULL
OR r.stops IS NULL
DETACH DELETE r;

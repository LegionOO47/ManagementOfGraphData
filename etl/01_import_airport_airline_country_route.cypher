// NOTE: The following script syntax is valid for database version 5.0 and above.

:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'file:///', // Change this to the folder your script can access the files at.
  file_0: 'airport.csv',
  file_1: 'airlines.csv',
  file_2: 'countries.csv',
  file_3: 'routes.csv'
};

// CONSTRAINT creation
// -------------------
//
// Create node uniqueness constraints, ensuring no duplicates for the given node label and ID property exist in the database. This also ensures no duplicates are introduced in future.
//
CREATE CONSTRAINT `airportId_Airport_uniq` IF NOT EXISTS
FOR (n: `Airport`)
REQUIRE (n.`airportId`) IS UNIQUE;
CREATE CONSTRAINT `airlineId_Airline_uniq` IF NOT EXISTS
FOR (n: `Airline`)
REQUIRE (n.`airlineId`) IS UNIQUE;
CREATE CONSTRAINT `iso_Country_uniq` IF NOT EXISTS
FOR (n: `Country`)
REQUIRE (n.`iso`) IS UNIQUE;

:param {
  idsToSkip: []
};

// NODE load
// ---------
//
// Load nodes in batches, one node label at a time. Nodes will be created using a MERGE statement to ensure a node with the same label and ID property remains unique. Pre-existing nodes found by a MERGE statement will have their other properties set to the latest values encountered in a load file.
//
// NOTE: Any nodes with IDs in the 'idsToSkip' list parameter will not be loaded.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`Airport ID` IN $idsToSkip AND NOT toInteger(trim(row.`Airport ID`)) IS NULL
CALL (row) {
  MERGE (n: `Airport` { `airportId`: toInteger(trim(row.`Airport ID`)) })
  SET n.`airportId` = toInteger(trim(row.`Airport ID`))
  SET n.`iata` = row.`IATA`
  SET n.`icao` = row.`ICAO`
  SET n.`airportName` = row.`Name`
  SET n.`city` = row.`City`
  SET n.`countryName` = row.`Country`
  SET n.`lat` = toFloat(trim(row.`Latitude`))
  SET n.`lon` = toFloat(trim(row.`Longitude`))
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`Airline ID` IN $idsToSkip AND NOT toInteger(trim(row.`Airline ID`)) IS NULL
CALL (row) {
  MERGE (n: `Airline` { `airlineId`: toInteger(trim(row.`Airline ID`)) })
  SET n.`airlineId` = toInteger(trim(row.`Airline ID`))
  SET n.`name` = row.`Name`
  SET n.`iata` = row.`IATA`
  SET n.`icao` = row.`ICAO`
  SET n.`active` = row.`Active`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`iso_code` IN $idsToSkip AND NOT row.`iso_code` IS NULL
CALL (row) {
  MERGE (n: `Country` { `iso`: row.`iso_code` })
  SET n.`iso` = row.`iso_code`
  SET n.`name` = row.`name`
} IN TRANSACTIONS OF 10000 ROWS;


// RELATIONSHIP load
// -----------------
//
// Load relationships in batches, one relationship type at a time. Relationships are created using a MERGE statement, meaning only one relationship of a given type will ever be created between a pair of nodes.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row 
CALL (row) {
  MATCH (source: `Airport` { `airportId`: toInteger(trim(row.`Source airport ID`)) })
  MATCH (target: `Airport` { `airportId`: toInteger(trim(row.`Destination airport ID`)) })
  MERGE (source)-[r: `ROUTE`]->(target)
  SET r.`airlinecode` = row.`Airline`
  SET r.`airlineId` = toInteger(trim(row.`Airline ID`))
  SET r.`codeShare` = row.`Codeshare`
  SET r.`stops` = toLower(trim(row.`Stops`)) IN ['1','true','yes']
  SET r.`equipment` = row.`Equipment`
  SET r.`distance_km` = toFloat(trim(row.`distance`))
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (a:Airport)-[:LOCATED_IN]->(c:Country)
WHERE
  // Match by airport name
  toLower(a.airportName) CONTAINS toLower($q)
  OR
  // Match by city
  toLower(a.city) CONTAINS toLower($q)
  OR
  // Match by IATA or ICAO
  toLower(coalesce(a.iata,'')) = toLower($q)
  OR toLower(coalesce(a.icao,'')) = toLower($q)
  OR
  // Match by country name
  toLower(c.name) CONTAINS toLower($q)
RETURN
  a.airportId AS airportId,
  a.iata AS iata,
  a.icao AS icao,
  a.airportName AS name,
  a.city AS city,
  c.name AS country
ORDER BY name ASC
LIMIT 20;
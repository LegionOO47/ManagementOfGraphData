MATCH (a:Airport)
WHERE 
  toLower(a.airportName) CONTAINS toLower($q) OR
  toLower(a.city) CONTAINS toLower($q) OR
  toLower(coalesce(a.iata, '')) = toLower($q) OR
  toLower(coalesce(a.icao, '')) = toLower($q)
RETURN 
  a.airportId AS airportId, 
  a.iata AS iata, 
  a.icao AS icao,
  a.airportName AS name,
  a.city AS city
ORDER BY name ASC
LIMIT 20;

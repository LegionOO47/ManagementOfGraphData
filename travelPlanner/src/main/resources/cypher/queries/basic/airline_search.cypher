MATCH (al:Airline)
WHERE
  toLower(al.name) CONTAINS toLower($q)
  OR toLower(coalesce(al.iata, '')) = toLower($q)
  OR toLower(coalesce(al.icao, '')) = toLower($q)
  OR toLower(coalesce(al.active, '')) = toLower($q)
WITH al
// Optional: filter only active airlines if enabled
WHERE
  $activeOnly = false OR al.active = 'Y'
RETURN 
  al.airlineId AS airlineId,
  al.name AS name,
  al.iata AS iata,
  al.icao AS icao,
  al.active AS active
ORDER BY name ASC
LIMIT 20;

MATCH (a:Airport)-[r:ROUTE]->()
RETURN 
  a.airportId AS airportId,
  a.iata AS iata,
  a.airportName AS name,
  a.city AS city,
  count(r) AS outgoingRoutes
ORDER BY outgoingRoutes DESC
LIMIT 10;

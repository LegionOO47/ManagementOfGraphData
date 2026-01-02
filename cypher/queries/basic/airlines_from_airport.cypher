MATCH (src:Airport {iata: $srcIata})-[r:ROUTE]->(dst:Airport)
MATCH (al:Airline {airlineId: r.airlineId})
RETURN 
  al.airlineId AS airlineId,
  al.iata AS airlineCode,
  al.name AS airlineName,
  count(r) AS numRoutesFromSrc,
  collect(distinct dst.iata)[0..10] AS sampleDestinations
ORDER BY numRoutesFromSrc DESC;

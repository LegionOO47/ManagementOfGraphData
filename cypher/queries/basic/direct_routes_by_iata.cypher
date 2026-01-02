MATCH (src:Airport {iata: $srcIata})
MATCH (dst:Airport {iata: $dstIata})
MATCH (src)-[r:ROUTE]->(dst)
OPTIONAL MATCH (al:Airline {airlineId: r.airlineId})
RETURN
  src.iata AS source,
  dst.iata AS destination,
  al.name AS airlineName,
  al.iata AS airlineCode,
  r.distance_km AS distanceKm,
  r.stops AS stops,
  r.equipment AS equipment
ORDER BY distanceKm ASC;
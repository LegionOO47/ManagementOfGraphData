MATCH (src:Airport {iata:$srcIata}),
      (dst:Airport {iata:$dstIata})

// Collect active airlines first
MATCH (al:Airline)
WHERE al.active = 'Y'
WITH src, dst, collect(al.airlineId) AS activeAirlineIds, 
     $maxHops AS maxHops,
     $blockedAirlines AS blockedAirlines

CALL {
  WITH src, dst, activeAirlineIds, blockedAirlines, maxHops
  // hop = 1
  MATCH p1 = (src)-[:ROUTE]->(dst)
  WHERE maxHops >= 1
    AND ALL(rel IN relationships(p1) WHERE rel.airlineId IN activeAirlineIds)
    AND NONE(rel IN relationships(p1) WHERE rel.airlinecode IN blockedAirlines)
  RETURN p1 AS path

  UNION

  WITH src, dst, activeAirlineIds, blockedAirlines, maxHops
  // hop = 2
  MATCH p2 = (src)-[:ROUTE*2]->(dst)
  WHERE maxHops >= 2
    AND ALL(rel IN relationships(p2) WHERE rel.airlineId IN activeAirlineIds)
    AND NONE(rel IN relationships(p2) WHERE rel.airlinecode IN blockedAirlines)
  RETURN p2 AS path

  UNION

  WITH src, dst, activeAirlineIds, blockedAirlines, maxHops
  // hop = 3
  MATCH p3 = (src)-[:ROUTE*3]->(dst)
  WHERE maxHops >= 3
    AND ALL(rel IN relationships(p3) WHERE rel.airlineId IN activeAirlineIds)
    AND NONE(rel IN relationships(p3) WHERE rel.airlinecode IN blockedAirlines)
  RETURN p3 AS path
}

WITH path,
     length(path) AS hops,
     relationships(path) AS rels
WITH path, hops, rels,
     REDUCE(d = 0.0, rel IN rels | d + rel.distance_km) AS distanceKm
UNWIND rels AS r
MATCH (air:Airline {airlineId:r.airlineId})
WITH path, hops, distanceKm,
     collect(DISTINCT air.name) AS airlinesNames,
     collect(DISTINCT air.iata) AS airlinesIATA,
     collect(DISTINCT air.icao) AS airlinesICAO
RETURN
  [n IN nodes(path) | n.iata] AS routeIataPath,
  hops,
  distanceKm,
  airlinesIATA,
  airlinesNames,
[n IN nodes(path) | n.countryName] AS countriesPath,
  apoc.coll.toSet([n IN nodes(path)[1..-1] | n.countryName]) AS transitCountries
  
ORDER BY hops, distanceKm ASC
LIMIT $limit;
MATCH (src:Airport {iata:$srcIata}),
      (dst:Airport {iata:$dstIata})

MATCH (al:Airline)
WHERE al.active = 'Y'
WITH src, dst, collect(al.airlineId) AS activeAirlineIds, $maxHops AS maxHops

CALL {
  WITH src, dst, activeAirlineIds, maxHops
  // hop = 1
  MATCH p1 = (src)-[:ROUTE]->(dst)
  WHERE maxHops >= 1
    AND ALL(rel IN relationships(p1) WHERE rel.airlineId IN activeAirlineIds)
  RETURN p1 AS path

  UNION

  WITH src, dst, activeAirlineIds, maxHops
  // hop = 2
  MATCH p2 = (src)-[:ROUTE*2]->(dst)
  WHERE maxHops >= 2
    AND ALL(rel IN relationships(p2) WHERE rel.airlineId IN activeAirlineIds)
  RETURN p2 AS path

  UNION

  WITH src, dst, activeAirlineIds, maxHops
  // hop = 3
  MATCH p3 = (src)-[:ROUTE*3]->(dst)
  WHERE maxHops >= 3
    AND ALL(rel IN relationships(p3) WHERE rel.airlineId IN activeAirlineIds)
  RETURN p3 AS path
}

WITH path,
     length(path) AS hops,
     REDUCE(d = 0.0, rel IN relationships(path) | d + rel.distance_km) AS distanceKm,
     relationships(path) AS rels

// Lookup airline nodes to extract airline codes / names
MATCH (air:Airline)
WHERE air.airlineId IN [r IN rels | r.airlineId]
WITH path, hops, distanceKm, rels,
     collect(air.airlineId) AS airlinesUsedIds,
     collect(air.iata) AS airlinesUsedCodes,    // If you prefer ICAO: collect(air.icao)
     collect(air.name) AS airlinesUsedNames

RETURN
  [n IN nodes(path) | n.iata] AS routeIataPath,
  hops,
  distanceKm,
  airlinesUsedCodes,
  airlinesUsedNames,
[n IN nodes(path) | n.countryName] AS countriesPath,
  apoc.coll.toSet([n IN nodes(path)[1..-1] | n.countryName]) AS transitCountries
ORDER BY hops, distanceKm ASC
LIMIT $limit;

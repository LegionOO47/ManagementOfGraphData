MATCH (src:Airport {iata:$srcIata}),
      (dst:Airport {iata:$dstIata})

MATCH (al:Airline)
WHERE al.active = 'Y'
WITH src, dst,
     collect(al.airlineId) AS activeAirlineIds,
     coalesce($maxHops, 3) AS maxHops,
     coalesce($blockedAirlines, []) AS blockedAirlines,
     coalesce($blockedCountries, []) AS blockedCountries,
     500 AS stopPenaltyKm

CALL {
  WITH src, dst, activeAirlineIds, blockedAirlines, blockedCountries, maxHops
  MATCH p1=(src)-[:ROUTE]->(dst)
  WHERE maxHops >= 1
    AND ALL(rel IN relationships(p1) WHERE rel.airlineId IN activeAirlineIds)
    AND NONE(rel IN relationships(p1) WHERE rel.airlineId IN blockedAirlines)
    AND NONE(node IN nodes(p1)[1..-1] WHERE node.countryName IN blockedCountries)
  RETURN p1 AS path
  UNION
  WITH src, dst, activeAirlineIds, blockedAirlines, blockedCountries, maxHops
  MATCH p2=(src)-[:ROUTE*2]->(dst)
  WHERE maxHops >= 2
    AND ALL(rel IN relationships(p2) WHERE rel.airlineId IN activeAirlineIds)
    AND NONE(rel IN relationships(p2) WHERE rel.airlineId IN blockedAirlines)
    AND NONE(node IN nodes(p2)[1..-1] WHERE node.countryName IN blockedCountries)
  RETURN p2 AS path
  UNION
  WITH src, dst, activeAirlineIds, blockedAirlines, blockedCountries, maxHops
  MATCH p3=(src)-[:ROUTE*3]->(dst)
  WHERE maxHops >= 3
    AND ALL(rel IN relationships(p3) WHERE rel.airlineId IN activeAirlineIds)
    AND NONE(rel IN relationships(p3) WHERE rel.airlineId IN blockedAirlines)
    AND NONE(node IN nodes(p3)[1..-1] WHERE node.countryName IN blockedCountries)
  RETURN p3 AS path
}

WITH path,
     length(path) AS hops,
     relationships(path) AS rels,
     stopPenaltyKm

WITH path, hops, rels,
     REDUCE(d = 0.0, rel IN rels | d + rel.distance_km) AS distanceKm,
     (hops - 1) AS stops,
     stopPenaltyKm

WITH path, hops, rels, distanceKm, stops,
     distanceKm + stops * stopPenaltyKm AS score

UNWIND rels AS r
MATCH (air:Airline {airlineId:r.airlineId})

WITH path, hops, distanceKm, stops, score,
     collect(DISTINCT air.name) AS airlinesNames,
     collect(DISTINCT air.iata) AS airlinesIATA,
     [n IN nodes(path) | n.countryName] AS countriesPath,
     apoc.coll.toSet([n IN nodes(path)[1..-1] | n.countryName]) AS transitCountries

RETURN
  round(score) AS score,
  [n IN nodes(path) | n.iata] AS routeIataPath,
    [n IN nodes(path) | n.city]        AS citiesPath,

  countriesPath,
  transitCountries,
  stops,
  hops,
  distanceKm,
  airlinesNames
ORDER BY score ASC
LIMIT $limit;
WITH $origin AS originCity,
     $cities AS cityNames

// ===================================================
// Step 0: Select best airport for origin city
// ===================================================
MATCH (o:Airport)
WHERE toLower(o.city) = toLower(originCity)
WITH originCity, cityNames, o,
     COUNT { (o)-[:ROUTE]->() } AS routeCount
ORDER BY routeCount DESC
WITH cityNames, collect(o)[0] AS originAirport

// ===================================================
// Step 1: Select best airport per requested city
// ===================================================
UNWIND cityNames AS city
MATCH (a:Airport)
WHERE toLower(a.city) = toLower(city)
WITH originAirport, city, a,
     COUNT { (a)-[:ROUTE]->() } AS routeCount
ORDER BY city, routeCount DESC
WITH originAirport, city, collect(a)[0] AS bestAirport
WITH originAirport, collect(bestAirport) AS cityAirports

// ===================================================
// Step 2: Manual permutations (max 6 cities)
// ===================================================
UNWIND cityAirports AS a1
WITH originAirport, cityAirports, a1,
     [x IN cityAirports WHERE x <> a1] AS r1

UNWIND r1 AS a2
WITH originAirport, a1, a2,
     [x IN r1 WHERE x <> a2] AS r2

UNWIND CASE WHEN size(r2) = 0 THEN [null] ELSE r2 END AS a3
WITH originAirport, a1, a2, a3,
     CASE WHEN a3 IS NULL THEN [] ELSE [x IN r2 WHERE x <> a3] END AS r3

UNWIND CASE WHEN size(r3) = 0 THEN [null] ELSE r3 END AS a4
WITH originAirport, a1, a2, a3, a4,
     CASE WHEN a4 IS NULL THEN [] ELSE [x IN r3 WHERE x <> a4] END AS r4

UNWIND CASE WHEN size(r4) = 0 THEN [null] ELSE r4 END AS a5
WITH originAirport, a1, a2, a3, a4, a5,
     CASE WHEN a5 IS NULL THEN [] ELSE [x IN r4 WHERE x <> a5] END AS r5

UNWIND CASE WHEN size(r5) = 0 THEN [null] ELSE r5 END AS a6

WITH originAirport,
     [x IN [a1,a2,a3,a4,a5,a6] WHERE x IS NOT NULL] AS visitOrder

// ===================================================
// Step 3: Build round trip (origin → cities → origin)
// ===================================================
WITH originAirport AS origin, visitOrder,
     [originAirport] + visitOrder + [originAirport] AS fullOrder

// ===================================================
// Step 4: Shortest paths + distance + layovers (unchanged)
// ===================================================
CALL {
  WITH fullOrder
  UNWIND range(0, size(fullOrder)-2) AS i
  WITH fullOrder[i] AS src, fullOrder[i+1] AS dst
  MATCH p = shortestPath((src)-[:ROUTE*1..3]->(dst))
  WITH
    p,
    length(p) AS hops,
    REDUCE(d = 0.0, r IN relationships(p) | d + r.distance_km) AS dist,
    nodes(p) AS pathNodes
  RETURN
    sum(dist) AS totalDistanceKm,
    sum(hops - 1) AS totalStops,
    collect(pathNodes) AS allPathNodes
}

// ===================================================
// Step 5: Extract actual visited cities
// ===================================================
WITH visitOrder, totalDistanceKm, totalStops, allPathNodes,
     reduce(acc = [], pn IN allPathNodes | acc + pn) AS flatNodes

WITH visitOrder, totalDistanceKm, totalStops,
     [n IN flatNodes | n.city] AS actualVisitedCities,
     (totalDistanceKm + totalStops * 500) AS score

// ===================================================
// Final output
// ===================================================
RETURN
  [a IN visitOrder | a.iata] AS visitAirportOrder,
  [a IN visitOrder | a.city] AS visitCityOrder,
  actualVisitedCities AS actualVisitedCitiesWithLayovers,
  round(totalDistanceKm) AS distanceKm,
  totalStops,
  round(score) AS score
ORDER BY score ASC
LIMIT 20;
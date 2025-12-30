MATCH (from:Airport)-[r:ROUTE]->(to:Airport)
OPTIONAL MATCH (airline:Airline {airlineId: r.airlineId})
WITH airline, from, to
WHERE airline IS NOT NULL
MERGE (airline)-[:OPERATES]->(from)
MERGE (airline)-[:OPERATES]->(to);

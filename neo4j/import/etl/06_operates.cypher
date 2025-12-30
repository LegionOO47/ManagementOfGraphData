MATCH (from:Airport)-[r:ROUTE]->(to:Airport)
OPTIONAL MATCH (airline:Airline {airlineId: r.airlineId})
WITH airline, from, to
WHERE airline          // only keeps rows where airline exists
MERGE (airline)-[:OPERATES]->(from)
MERGE (airline)-[:OPERATES]->(to);


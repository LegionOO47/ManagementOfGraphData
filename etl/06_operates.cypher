MATCH (from:Airport)-[r:ROUTE]->(to:Airport)
MATCH (airline:Airline {airlineId: r.airlineId})
MERGE (airline)-[:OPERATES]->(from)
MERGE (airline)-[:OPERATES]->(to);


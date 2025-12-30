MATCH (a:Airport)
MATCH (c:Country {name: a.countryName})
MERGE (a)-[:LOCATED_IN]->(c);

//Delete airports without a country
MATCH (a:Airport)
WHERE NOT (a)-[:LOCATED_IN]->(:Country)
DETACH DELETE a;

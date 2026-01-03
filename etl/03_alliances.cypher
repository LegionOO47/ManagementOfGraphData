//Delete inactive airlines
MATCH (al:Airline)
WHERE NOT al.active = 'Y'
DETACH DELETE al;

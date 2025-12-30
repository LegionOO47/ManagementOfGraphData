//This is for decimal degrees as thats in the dataset
MATCH (a1:Airport)-[r:ROUTE]->(a2:Airport)
WITH a1, a2, r,
     radians(a2.lat - a1.lat) AS dLat,
     radians(a2.lon - a1.lon) AS dLon,
     radians(a1.lat) AS lat1,
     radians(a2.lat) AS lat2
WITH r,
     2 * 6371 *
     asin(
       sqrt(
         sin(dLat / 2)^2 +
         cos(lat1) * cos(lat2) * sin(dLon / 2)^2
       )
     ) AS distanceKm
SET r.distance_km = distanceKm;

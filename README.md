# ManagementOfGraphData

## Docker
To launch: docker compose up
To close: docker compose down
To force rebuild on next launch: docker compose down -v

Neo4j weblink: http://localhost:7474/browser/
user: neo4j
password: Qwertz123!

## Data Model

Airport(airportId, iata?, airportName, city, countryName, lat, lon)
Airline(airlineId, name, iata?, icao?, active)
Country(name,iso)

(Airport) -> (:ROUTE (airlineId, airlineCode?, codeShare?, equipment?, stops, distance_KM) -> (Airport)

(Airline) -> (:OPERATES) -> (Airport)

(Airport) -> (:LOCATED_IN) -> (Country)

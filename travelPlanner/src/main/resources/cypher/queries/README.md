# Flight Routing & Optimization – Cypher Queries

This folder contains all Cypher queries used by the flight routing application.
Each query is parameterized and designed to be executed directly from the backend
(using the Neo4j driver).

---

## 📁 basic/

These queries support **search, exploration, and browsing** features.

### airport_search.cypher

**Purpose**
Search airports by name, city, IATA, or ICAO code.

**Used for**

- Autocomplete
- Airport search input
- Airport selection UI

**Parameters**

- `$q` (string): search keyword

**Returns**

- airportId, iata, icao, name, city

---

### airline_search.cypher

**Purpose**
Search airlines by name or code, optionally filtering active airlines only.

**Used for**

- Airline selection
- Filter UI (e.g., avoid airline)

**Parameters**

- `$q` (string)
- `$activeOnly` (boolean)

**Returns**

- airlineId, name, iata, icao, active

---

### search_airport_by_input.cypher

**Purpose**
Search airports by airport name, city, code, or country name.

**Used for**

- Unified search bar
- Country-based discovery

**Parameters**

- `$q` (string)

**Returns**

- airport info + country name

---

### direct_routes_by_iata.cypher

**Purpose**
List all direct flights between two airports.

**Used for**

- Showing direct flight availability
- Route inspection

**Parameters**

- `$srcIata`
- `$dstIata`

**Returns**

- airline name/code
- distance
- stops
- equipment

---

### top_hubs.cypher

**Purpose**
Rank airports by number of outgoing routes.

**Used for**

- Analytics
- Hub discovery
- UI recommendations

**Returns**

- airport info + outgoingRoutes count

---

### airlines_from_airport.cypher

**Purpose**
List airlines operating from a given airport.

**Used for**

- Airline filters
- Airport capability overview

**Parameters**

- `$srcIata`

**Returns**

- airline info
- number of routes
- sample destinations

---

## 📁 advanced/

These queries support **advanced routing between two airports**.

---

### route_active_airlines.cypher

**Purpose**
Find routes using only active airlines with bounded hops (≤ 3).

**Used for**

- Basic routing search
- Default route discovery

**Parameters**

- `$srcIata`
- `$dstIata`
- `$maxHops`
- `$limit`

---

### route_avoid_airlines.cypher

**Purpose**
Find routes while excluding specific airlines.

**Used for**

- “Avoid airline” feature

**Parameters**

- `$srcIata`
- `$dstIata`
- `$maxHops`
- `$blockedAirlines`
- `$limit`

---

### route_avoid_countries.cypher

**Purpose**
Find routes while avoiding specific transit countries.

**Used for**

- Visa restrictions
- User preferences

**Parameters**

- `$srcIata`
- `$dstIata`
- `$maxHops`
- `$blockedCountries`
- `$blockedAirlines`
- `$limit`

---

### route_best_score.cypher

**Purpose**
Rank routes using a scoring function:  
score = distanceKm + (stops × 500)

**Used for**

- Best route recommendation
- Default routing result

**Parameters**

- `$srcIata`
- `$dstIata`
- `$maxHops`
- `$blockedAirlines`
- `$blockedCountries`
- `$limit`

**Returns**

- route path
- score
- distance
- stops
- airlines
- transit countries

---

This queries support **multi-city trip planning**.

---

### multi_city_route_optimization.cypher

**Purpose**
Optimize the visiting order of multiple cities, including layovers.

**Key Features**

- Manual permutation generation (up to 6 cities)
- Shortest path per segment (≤ 3 hops)
- Explicit stop penalty
- Layover city extraction
- Global itinerary scoring

**Used for**

- “Plan multi-city trip” feature
- Advanced travel planning

**Parameters**

- `$origin` (city name)
- `$cities` (list of city names)

**Returns**

- optimized visit order
- full travel order including layovers
- total distance
- total stops
- final score

---

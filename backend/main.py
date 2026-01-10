from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from neo4j import GraphDatabase
from typing import List, Optional
import os

# --- CONFIGURATION ---
# Make sure this matches your Neo4j Desktop settings!
URI = "bolt://localhost:7687"
AUTH = ("neo4j", "Pak@13579")  # <--- Change "1234" to "password" if that is what you used

# Initialize App and Database Driver
app = FastAPI(title="Airplane Route Planner")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
driver = GraphDatabase.driver(URI, auth=AUTH)

def run_query(query, parameters=None):
    with driver.session() as session:
        result = session.run(query, parameters)
        return [record.data() for record in result]

@app.get("/")
def read_root():
    return {"status": "Backend is running!", "project": "Airplane Route Planner"}

@app.get("/test-db")
def test_db_connection():
    try:
        query = "MATCH (a:Airport) RETURN count(a) as count"
        data = run_query(query)
        return {"message": "Connection Successful", "airport_count": data[0]['count']}
    except Exception as e:
        return {"error": str(e)}

@app.get("/airports/search")
def search_airports(q: str):
    query = """
    MATCH (a:Airport)
    WHERE toLower(a.city) CONTAINS toLower($q) 
       OR toLower(a.airportName) CONTAINS toLower($q) 
       OR toLower(a.iata) CONTAINS toLower($q)
    RETURN a.airportId as id, a.iata as iata, a.airportName as name, a.city as city, a.countryName as country
    LIMIT 10
    """
    return run_query(query, {"q": q})

# --- THE NEW ROUTE SEARCH ENDPOINT ---
@app.get("/routes/search")
def search_routes(
    src_id: int, 
    dst_id: int, 
    max_hops: int = 3,
    avoid_countries: Optional[List[str]] = Query(None),
    avoid_airlines: Optional[List[str]] = Query(None)
):
    # Handle empty lists
    if avoid_countries is None: avoid_countries = []
    if avoid_airlines is None: avoid_airlines = []

    # Cypher Query Logic
    cypher_query = f"""
    MATCH path = (start:Airport {{airportId: $src_id}})-[:ROUTE*1..{max_hops}]->(end:Airport {{airportId: $dst_id}})
    
    // Constraint 1: Avoid Countries (Check all intermediate nodes)
    WHERE ALL(node IN nodes(path) WHERE NOT node.countryName IN $avoid_countries)
    
    // Constraint 2: Avoid Airlines (Check all relationships)
    AND ALL(rel IN relationships(path) WHERE NOT rel.airlinecode IN $avoid_airlines)

    // Return the path details
    RETURN 
        [node in nodes(path) | {{name: node.airportName, city: node.city, country: node.countryName, id: node.airportId, lat: node.lat, lon: node.lon}}] as airports,
        [rel in relationships(path) | {{airline: rel.airlinecode, stops: rel.stops, distance: rel.distance_km}}] as flights,
        reduce(totalDist = 0.0, r in relationships(path) | totalDist + r.distance_km) as total_distance,
        length(path) as hops
    ORDER BY total_distance ASC
    LIMIT 5
    """
    
    parameters = {
        "src_id": src_id,
        "dst_id": dst_id,
        "avoid_countries": avoid_countries,
        "avoid_airlines": avoid_airlines
    }

    return run_query(cypher_query, parameters)
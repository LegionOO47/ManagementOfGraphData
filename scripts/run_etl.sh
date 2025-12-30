#!/bin/bash
set -e

# Wait for Neo4j to be ready
echo "Waiting for Neo4j to start..."
until cypher-shell -a bolt://neo4j:7687 -u $NEO4J_USERNAME -p $NEO4J_PASSWORD "RETURN 1" >/dev/null 2>&1
do
  sleep 2
done

# List of ETL scripts in order
ETL_SCRIPTS=(
    "/etl/00_constraints.cypher"
    "/etl/01_import_airport_airline_country_route.cypher"
    "/etl/02_located_in.cypher"
    "/etl/05_distance_km.cypher"
    "/etl/06_operates.cypher"
)

# Run each ETL script
for script in "${ETL_SCRIPTS[@]}"; do
    echo "Running $script..."
    cypher-shell -a bolt://neo4j:7687 -u $NEO4J_USERNAME -p $NEO4J_PASSWORD -f "$script"
done

echo "All ETL scripts executed."


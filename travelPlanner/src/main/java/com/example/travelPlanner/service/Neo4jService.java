package com.example.travelPlanner.service;

import org.neo4j.driver.Driver;
import org.neo4j.driver.Session;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class Neo4jService {

    private final Driver driver;
    private final CypherLoader loader;

    public Neo4jService(Driver driver, CypherLoader loader) {
        this.driver = driver;
        this.loader = loader;
    }

    public List<Map<String, Object>> run(String cypherFile, Map<String, Object> params) {
        String cypher = loader.load(cypherFile);

        try (Session session = driver.session()) {
            return session.run(cypher, params)
                    .list(r -> r.asMap());
        }
    }
}


package com.example.travelPlanner.service;

import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Component
public class CypherLoader {

    public String load(String path) {
        try (InputStream is =
                     getClass().getResourceAsStream("/cypher/queries/" + path)) {

            if (is == null) {
                throw new RuntimeException("Cypher file not found: " + path);
            }

            return new String(is.readAllBytes(), StandardCharsets.UTF_8);

        } catch (Exception e) {
            throw new RuntimeException("Cannot load cypher: " + path, e);
        }
    }
}


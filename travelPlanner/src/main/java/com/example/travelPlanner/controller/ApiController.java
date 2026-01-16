package com.example.travelPlanner.controller;
import com.example.travelPlanner.service.Neo4jService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ApiController {


    private final Neo4jService neo4j;

    public ApiController(Neo4jService neo4j) {
        this.neo4j = neo4j;
    }


                                                                        //Auto complete and search
    //GET /api/autocomplete/airports?q=vie
    @GetMapping("/autocomplete/airports")
    public List<Map<String,Object>> airportAutocomplete(@RequestParam String q) {
        return neo4j.run("basic/airport_search.cypher", Map.of("q", q));
    }

    //GET /api/autocomplete/airlines?q=lufthansa&activeOnly=true

    @GetMapping("/autocomplete/airlines")
    public List<Map<String,Object>> airlineAutocomplete(
            @RequestParam String q,
            @RequestParam(defaultValue = "false") boolean activeOnly
    ) {
        return neo4j.run("basic/airline_search.cypher",
                Map.of("q", q, "activeOnly", activeOnly));
    }

    //GET /api/search/airports?q=vienna
    @GetMapping("/search/airports")
    public List<Map<String,Object>> searchAirports(@RequestParam String q) {
        return neo4j.run("basic/search_airport_by_input.cypher", Map.of("q", q));
    }

    //GET /api/airports/VIE/airlines
    @GetMapping("/airports/{iata}/airlines")
    public List<Map<String,Object>> airlinesFromAirport(@PathVariable String iata) {
        return neo4j.run("basic/airlines_from_airport.cypher",
                Map.of("srcIata", iata));
    }

    //GET /api/routes/direct?srcIata=VIE&dstIata=FRA
    @GetMapping("/routes/direct")
    public List<Map<String,Object>> directRoutes(
            @RequestParam String srcIata,
            @RequestParam String dstIata
    ) {
        return neo4j.run("basic/direct_routes_by_iata.cypher",
                Map.of("srcIata", srcIata, "dstIata", dstIata));
    }


    //GET /api/analytics/hubs
    @GetMapping("/analytics/hubs")
    public List<Map<String,Object>> topHubs() {
        return neo4j.run("basic/top_hubs.cypher", Map.of());
    }


    //POST /api/routes/search
    /* request jsn example
{
  "srcIata": "VIE",
  "dstIata": "JFK",
  "maxHops": 3,
  "blockedAirlines": [220, 137],
  "blockedCountries": ["Germany"],
  "bestScore": true,
  "limit": 10
}
    * */

    @PostMapping("/routes/search")
    public List<Map<String,Object>> searchRoutes(@RequestBody Map<String,Object> body) {

        String file;

        boolean best = (boolean) body.getOrDefault("bestScore", false);
        List<?> blockedCountries = (List<?>) body.getOrDefault("blockedCountries", List.of());
        List<?> blockedAirlines = (List<?>) body.getOrDefault("blockedAirlines", List.of());

        if (best) {
            file = "advanced/best_score_route.cypher";
        } else if (!blockedCountries.isEmpty()) {
            file = "advanced/Avoid_airlines_countries.cypher";
        } else if (!blockedAirlines.isEmpty()) {
            file = "advanced/avoid_airlines.cypher";
        } else {
            file = "advanced/max_stop_active_airlines.cypher";
        }

        return neo4j.run(file, body);
    }

    //POST /api/routes/multicity

    @PostMapping("/routes/multicity")
    public List<Map<String,Object>> multiCity(@RequestBody Map<String,Object> body) {
        return neo4j.run("advanced/multi_city_route_optimizer.cypher", body);
    }

    @GetMapping("/health")
    public String health() {
        return "Backend is running";
    }

}

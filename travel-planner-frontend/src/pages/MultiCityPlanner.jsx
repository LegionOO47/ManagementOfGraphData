import { useState } from "react";
import {
  Box,
  Button,
  Container,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  CircularProgress
} from "@mui/material";

import AirportAutocomplete from "../components/AirportAutocomplete";
import api from "../api";

export default function MultiCityPlanner() {
  const [origin, setOrigin] = useState(null);
  const [cities, setCities] = useState([]);
  const [result, setResult] = useState([]);
  const [loading, setLoading] = useState(false);

  const addCity = (airport) => {
    if (!airport) return;
  
    //  destination equals origin
    if (origin && airport.airportId === origin.airportId) {
      alert("Destination city cannot be the same as the origin.");
      return;
    }
  
    //  duplicate destination
    if (cities.find(c => c.airportId === airport.airportId)) {
      alert("This destination city is already added.");
      return;
    }
  
    //  max 3 destinations
    if (cities.length >= 3) {
      alert("You can select at most 3 destination cities.");
      return;
    }
  
    setCities([...cities, airport]);
  };
  
  const removeCity = (id) => {
    setCities(cities.filter(c => c.airportId !== id));
  };

  const optimizeTrip = async () => {
    if (!origin || cities.length < 2 || cities.length > 3) {
        alert("Please select between 2 and 3 destination cities.");
        return;
      }

    const body = {
      origin: origin.city,
      cities: cities.map(c => c.city)
    };

    try {
      setLoading(true);
      const res = await api.post("/routes/multicity", body);
      setResult(res.data);
    } catch (err) {
      console.error("Multi-city optimization failed", err);
      alert("Multi-city optimization failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" sx={{ mt: 4, mb: 3 }}>
        🌍 Multi-City Trip Planner
      </Typography>

      {/* INPUTS */}
      <Paper sx={{ p: 3, mb: 4 }}>
        <Box sx={{ display: "grid", gap: 3 }}>
          <AirportAutocomplete
            label="Origin City"
            value={origin}
            onChange={setOrigin}
          />

<AirportAutocomplete
  label="Add Destination City (max 3)"
  value={null}
  onChange={addCity}
  disabled={cities.length >= 3}
/>

          {/* Selected cities */}
          <Box>
            {cities.map(c => (
              <Box
                key={c.airportId}
                sx={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  borderBottom: "1px solid #eee",
                  py: 1
                }}
              >
                <Typography>
                  {c.city} ({c.iata})
                </Typography>
                <Button
                  size="small"
                  color="error"
                  onClick={() => removeCity(c.airportId)}
                >
                  Remove
                </Button>
              </Box>
            ))}
          </Box>

          <Button
            variant="contained"
            size="large"
            disabled={loading || !origin || cities.length < 2}
            onClick={optimizeTrip}
          >
            {loading ? <CircularProgress size={24} /> : "Optimize Trip"}
          </Button>
        </Box>
      </Paper>

      {/* RESULTS */}
      {result.length > 0 && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="h6" sx={{ mb: 2 }}>
            Optimized Itinerary
          </Typography>

          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Visit Order (Airports)</TableCell>
                <TableCell>Visit Order (Cities)</TableCell>
                <TableCell>Actual Cities (with Layovers)</TableCell>
                <TableCell>Distance (km)</TableCell>
                <TableCell>Layover Stops</TableCell>
                <TableCell>Score</TableCell>
              </TableRow>
            </TableHead>

            <TableBody>
              {result.map((r, idx) => (
                <TableRow key={idx}>
                  <TableCell>
                    {r.visitAirportOrder.join(" → ")}
                  </TableCell>
                  <TableCell>
                    {r.visitCityOrder.join(" → ")}
                  </TableCell>
                  <TableCell>
  {r.actualVisitedCitiesWithLayovers
    .filter((city, idx, arr) => arr.indexOf(city) === idx)
    .join(" → ")}
</TableCell>
                  <TableCell>{r.distanceKm}</TableCell>
                  <TableCell>{r.totalStops}</TableCell>
                  <TableCell>{r.score}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}
    </Container>
  );
}

import { useState } from "react";
import {
  Box,
  Button,
  Container,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Switch,
  FormControlLabel,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  CircularProgress
} from "@mui/material";

import AirportAutocomplete from "../components/AirportAutocomplete";
import AirlineAutocomplete from "../components/AirlineAutocomplete";
import CountryAutocomplete from "../components/CountryAutocomplete";
import api from "../api";

import FlightTakeoffIcon from "@mui/icons-material/FlightTakeoff";
import PublicIcon from "@mui/icons-material/Public";
import AirlineSeatReclineNormalIcon from "@mui/icons-material/AirlineSeatReclineNormal";
import StraightenIcon from "@mui/icons-material/Straighten";
import StarIcon from "@mui/icons-material/Star";


export default function RoutePlanner() {
  const [from, setFrom] = useState(null);
  const [to, setTo] = useState(null);
  const [blockedAirlines, setBlockedAirlines] = useState([]);
  const [maxHops, setMaxHops] = useState(3);
  const [bestScore, setBestScore] = useState(true);
  const [blockedCountries, setBlockedCountries] = useState([]);
  const [routes, setRoutes] = useState([]);
  const [loading, setLoading] = useState(false);

  const searchRoutes = async () => {
    if (!from || !to) return;
  
    if (from.airportId === to.airportId) {
      alert("Origin and destination airports must be different.");
      return;
    }

    const body = {
      srcIata: from.iata,
      dstIata: to.iata,
      maxHops,
      limit: 10,
      bestScore,
      blockedAirlines: blockedAirlines.map(a => a.airlineId),
      blockedCountries
    };

    try {
      setLoading(true);
      const res = await api.post("/routes/search", body);
      setRoutes(res.data);
    } catch (err) {
      console.error("Route search failed", err);
      alert("Route search failed. Check console.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" sx={{ mt: 4, mb: 3 }}>
        🔍 Route Planner
      </Typography>

      {/* INPUT FORM */}
      <Paper sx={{ p: 3, mb: 4 }}>
        <Box sx={{ display: "grid", gap: 3 }}>
          <AirportAutocomplete
            label="From"
            value={from}
            onChange={setFrom}
          />

          <AirportAutocomplete
            label="To"
            value={to}
            onChange={setTo}
          />

          <AirlineAutocomplete
            label="Avoid Airlines"
            value={blockedAirlines}
            onChange={setBlockedAirlines}
          />

            <CountryAutocomplete
            label="Avoid Countries"
            value={blockedCountries}
            onChange={setBlockedCountries}
            />


          <FormControl fullWidth>
            <InputLabel>Max Hops</InputLabel>
            <Select
              value={maxHops}
              label="Max Hops"
              onChange={(e) => setMaxHops(e.target.value)}
            >
              <MenuItem value={1}>1</MenuItem>
              <MenuItem value={2}>2</MenuItem>
              <MenuItem value={3}>3</MenuItem>
            </Select>
          </FormControl>

          <FormControlLabel
            control={
              <Switch
                checked={bestScore}
                onChange={(e) => setBestScore(e.target.checked)}
              />
            }
            label="Use best-score routing"
          />

          <Button
            variant="contained"
            size="large"
            onClick={searchRoutes}
            disabled={loading || !from || !to}
          >
            {loading ? <CircularProgress size={24} /> : "Search Routes"}
          </Button>
        </Box>
      </Paper>

      {/* RESULTS */}
      {routes.length > 0 && (
        <Paper sx={{ p: 2 }}>
          <Typography variant="h6" sx={{ mb: 2 }}>
            Results
          </Typography>

          <Table>
          <TableHead>
  <TableRow>
    <TableCell>Airports</TableCell>
    <TableCell>Cities</TableCell>
    <TableCell>Countries</TableCell>
    <TableCell>Hops</TableCell>
    <TableCell>Distance (km)</TableCell>
    <TableCell>Stops</TableCell>
    <TableCell>Airlines</TableCell>
    <TableCell>Score</TableCell>
  </TableRow>
</TableHead>


            <TableBody>
              {routes.map((r, idx) => (
                <TableRow key={idx}>
                {/* Airports */}
                <TableCell>
                  {r.routeIataPath?.join(" → ")}
                </TableCell>
              
                {/* Cities */}
                <TableCell>
                  {r.citiesPath
                    ? r.citiesPath.join(" → ")
                    : r.routeIataPath?.map(() => "-").join(" → ")}
                </TableCell>
              
                {/* Countries */}
                <TableCell>
                  {r.countriesPath?.join(" → ")}
                </TableCell>
              
                <TableCell>{r.hops}</TableCell>
                <TableCell>{Math.round(r.distanceKm)}</TableCell>
                <TableCell>{r.stops ?? r.hops - 1}</TableCell>
              
                {/* Airlines */}
                <TableCell>
                  {(r.airlinesNames || r.airlinesUsedNames || []).join(", ")}
                </TableCell>
              
                <TableCell>{r.score !== undefined ? Math.round(r.score) : "-"}</TableCell>
              </TableRow>
              
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}
    </Container>
  );
}

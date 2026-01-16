import { useEffect, useState } from "react";
import {
  Autocomplete,
  TextField,
  CircularProgress,
  Box,
  Typography
} from "@mui/material";
import api from "../api";

export default function AirportAutocomplete({
  label,
  value,
  onChange,
  disabled = false
}) {
  const [inputValue, setInputValue] = useState("");
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (inputValue.length < 2) {
      setOptions([]);
      return;
    }

    const timeout = setTimeout(async () => {
      try {
        setLoading(true);
        const res = await api.get(
          `/search/airports?q=${inputValue}`
        );
        setOptions(res.data);
      } catch (err) {
        console.error("Airport search failed", err);
      } finally {
        setLoading(false);
      }
    }, 400); // debounce

    return () => clearTimeout(timeout);
  }, [inputValue]);

  return (
    <Autocomplete
    disabled={disabled}
      options={options}
      value={value}
      filterOptions={(x) => x}  
      onChange={(e, newValue) => onChange(newValue)}
      getOptionLabel={(option) =>
        option
          ? `${option.name} (${option.iata})`
          : ""
      }
      isOptionEqualToValue={(opt, val) =>
        opt.airportId === val.airportId
      }
      loading={loading}
      onInputChange={(e, newInput) =>
        setInputValue(newInput)
      }
      renderOption={(props, option) => (
        <Box component="li" {...props} sx={{ py: 1 }}>
          <Box>
            <Typography fontWeight={600}>
              {option.name} ({option.iata})
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {option.city}, {option.country}
            </Typography>
          </Box>
        </Box>
      )}
      
      
      renderInput={(params) => (
        <TextField
          {...params}
          label={label}
          variant="outlined"
          InputProps={{
            ...params.InputProps,
            endAdornment: (
              <>
                {loading && (
                  <CircularProgress
                    color="inherit"
                    size={18}
                  />
                )}
                {params.InputProps.endAdornment}
              </>
            )
          }}
        />
      )}
    />
  );
}

import { useEffect, useState } from "react";
import {
  Autocomplete,
  TextField,
  CircularProgress,
  Box,
  Typography,
  Chip
} from "@mui/material";
import api from "../api";

export default function AirlineAutocomplete({
  label,
  value,
  onChange
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
          `/autocomplete/airlines?q=${inputValue}&activeOnly=true`
        );
        setOptions(res.data);
      } catch (err) {
        console.error("Airline search failed", err);
      } finally {
        setLoading(false);
      }
    }, 400);

    return () => clearTimeout(timeout);
  }, [inputValue]);

  return (
    <Autocomplete
      multiple
      options={options}
      value={value}
      onChange={(e, newValue) => onChange(newValue)}
      getOptionLabel={(option) =>
        option ? `${option.name} (${option.iata})` : ""
      }
      isOptionEqualToValue={(opt, val) =>
        opt.airlineId === val.airlineId
      }
      loading={loading}
      onInputChange={(e, newInput) =>
        setInputValue(newInput)
      }
      renderTags={(value, getTagProps) =>
        value.map((option, index) => (
          <Chip
            label={`${option.name} (${option.iata})`}
            {...getTagProps({ index })}
            key={option.airlineId}
          />
        ))
      }
      renderOption={(props, option) => (
        <Box component="li" {...props} sx={{ py: 1 }}>
          <Box>
            <Typography fontWeight={600}>
              {option.name}
            </Typography>
            <Typography
              variant="body2"
              color="text.secondary"
            >
              {option.iata} · {option.icao}
            </Typography>
          </Box>
        </Box>
      )}
      renderInput={(params) => (
        <TextField
          {...params}
          label={label}
          InputProps={{
            ...params.InputProps,
            endAdornment: (
              <>
                {loading && (
                  <CircularProgress
                    size={18}
                    color="inherit"
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

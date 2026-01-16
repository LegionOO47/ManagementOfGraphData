import { useEffect, useState } from "react";
import {
  Autocomplete,
  TextField,
  CircularProgress,
  Chip
} from "@mui/material";
import api from "../api";

export default function CountryAutocomplete({
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
          `/search/airports?q=${inputValue}`
        );

        // extract unique country names
        const uniqueCountries = [
          ...new Set(res.data.map(a => a.country))
        ];

        setOptions(uniqueCountries);
      } catch (err) {
        console.error("Country search failed", err);
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
      filterOptions={(x) => x}
      onInputChange={(e, newInput) =>
        setInputValue(newInput)
      }
      loading={loading}
      renderTags={(value, getTagProps) =>
        value.map((option, index) => (
          <Chip
            label={option}
            {...getTagProps({ index })}
            key={option}
          />
        ))
      }
      renderInput={(params) => (
        <TextField
          {...params}
          label={label}
          InputProps={{
            ...params.InputProps,
            endAdornment: (
              <>
                {loading && (
                  <CircularProgress size={18} />
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

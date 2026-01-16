import { AppBar, Tabs, Tab, Toolbar, Typography } from "@mui/material";
import { useLocation, useNavigate } from "react-router-dom";

export default function TopNav() {
  const location = useLocation();
  const navigate = useNavigate();

  const currentTab =
    location.pathname === "/multicity" ? 1 : 0;

  const handleChange = (e, newValue) => {
    if (newValue === 0) navigate("/");
    if (newValue === 1) navigate("/multicity");
  };

  return (
    <AppBar position="static" elevation={2}>
      <Toolbar sx={{ display: "flex", gap: 3 }}>
        <Typography variant="h6" sx={{ fontWeight: 600 }}>
          ✈ Travel Planner
        </Typography>

        <Tabs
          value={currentTab}
          onChange={handleChange}
          textColor="inherit"
          indicatorColor="secondary"
        >
          <Tab label="Route Planner" />
          <Tab label="Multi-City Planner" />
        </Tabs>
      </Toolbar>
    </AppBar>
  );
}

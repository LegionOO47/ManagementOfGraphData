import { BrowserRouter, Routes, Route } from "react-router-dom";
import RoutePlanner from "./pages/RoutePlanner";
import MultiCityPlanner from "./pages/MultiCityPlanner";
import TopNav from "./components/TopNav";

function App() {
  return (
    <BrowserRouter>
      <TopNav />
      <Routes>
        <Route path="/" element={<RoutePlanner />} />
        <Route path="/multicity" element={<MultiCityPlanner />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

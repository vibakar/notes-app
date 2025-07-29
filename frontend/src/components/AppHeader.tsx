import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";

export default function AppHeader() {
  return (
    <Box className="fg-1">
      <AppBar position="static">
        <Toolbar className="app-header">
          <Typography variant="h6" component="div" className="fg-1">
            Notes
          </Typography>
        </Toolbar>
      </AppBar>
    </Box>
  );
}

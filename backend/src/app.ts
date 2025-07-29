import express from "express";
import cors from "cors";
import noteRoutes from "./routes/note.route";
import { errorMiddleware } from "./middlewares/error.middleware";
import swaggerUi from "swagger-ui-express";
import * as fs from "fs";
import * as path from "path";
import yaml from "js-yaml";
const app = express();

const yamlPath = path.join(__dirname, "../swagger.yaml");
const swaggerDocument = yaml.load(fs.readFileSync(yamlPath, "utf8")) as object;
const allowedOrigins = process.env.CORS_ALLOWED_ORIGIN || [];

app.use(
  cors({
    origin: allowedOrigins,
    credentials: true,
  }),
);
app.use(express.json());
app.use(errorMiddleware);
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));
app.use("/api/v1/notes", noteRoutes);

export default app;

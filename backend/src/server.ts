import app from "./app";
import logger from "./utils/logger";

const PORT = Number(process.env.PORT) || 3000;

const startServer = async () => {
  const HOST = "0.0.0.0";
  app.listen(PORT, HOST, () => {
    logger.info(`Server running on port: ${PORT}`);
  });
};

startServer();

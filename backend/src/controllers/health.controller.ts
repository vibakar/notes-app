import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";
import logger from "../utils/logger";

const prisma = new PrismaClient();

export const healthCheck = async (req: Request, res: Response) => {
  logger.info("Incoming request for health check");
  try {
    logger.info("Checking database connection");
    await prisma.$queryRaw`SELECT 1`;
    logger.info("Databse connection successful");
    res.status(200).json({
      status: "ok",
      database: "connected",
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    logger.error(`Databse connection failed - ${error?.message || error}`);
    res.status(500).json({
      status: "error",
      database: "disconnected",
      error: error instanceof Error ? error.message : "Unknown error",
      timestamp: new Date().toISOString(),
    });
  }
};

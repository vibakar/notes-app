import { Request, Response, NextFunction } from "express";
import { HttpException } from "../exceptions/HttpException";

export const errorMiddleware = (
  err: Error | HttpException,
  req: Request,
  res: Response,
  _next: NextFunction,
) => {
  const status = err instanceof HttpException ? err.status : 500;
  const message = err.message || "Something went wrong";

  res.status(status).json({
    status,
    message,
  });
};

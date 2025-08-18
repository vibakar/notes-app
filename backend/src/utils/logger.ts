import pino from 'pino';
import path from 'path';

const getCallerFile = (): string => {
  const err = new Error();
  const stack = err.stack?.split('\n') || [];
  const callerLine = stack.find(
    (line) => !line.includes('logger.ts') && line.includes('at')
  );

  if (!callerLine) return 'unknown';

  const match = callerLine.match(/\((.*):\d+:\d+\)$/);
  if (!match) return 'unknown';

  return path.basename(match[1]);
};

const baseLogger = pino({
  level: process.env.LOG_LEVEL || 'debug',
  transport:
    process.env.NODE_ENV !== 'prod'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'SYS:standard',
            ignore: 'pid,hostname',
          },
        }
      : undefined,
});

const wrapLogMethod = (method: 'info' | 'error' | 'warn' | 'debug') => {
  return (msg: string | object, ...args: unknown[]) => {
    const file = getCallerFile();
    if (typeof msg === 'string') {
      baseLogger[method](`(${file}): ${msg}`, ...(args as any[]));
    } else {
      baseLogger[method](`(${file}): ${JSON.stringify(msg)}`, ...(args as any[]));
    }
  };
};

const logger = {
  info: wrapLogMethod('info'),
  error: wrapLogMethod('error'),
  warn: wrapLogMethod('warn'),
  debug: wrapLogMethod('debug'),
};

export default logger;

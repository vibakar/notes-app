locals {
  database_env = [
    { name = "POSTGRES_USER", value = "postgres" },
    { name = "POSTGRES_PASSWORD", value = "12345" },
    { name = "POSTGRES_DB", value = "postgres" },
  ]

  backend_env = [
    { name = "CORS_ALLOWED_ORIGIN", value = "http://notes-app.vibakar.com" },
    { name = "DATABASE_URL", value = "postgresql://postgres:12345@postgres.database.local:5432/postgres" },
    { name = "LOG_LEVEL", value = "debug" },
    { name = "NODE_ENV", value = "prod" },
  ]

  frontend_env = [
    { name = "VITE_API_BASE_URL", value = "http://notes-app.vibakar.com:3000" }
  ]
}
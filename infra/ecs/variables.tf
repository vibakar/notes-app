variable "frontend_image" {
  description = "Container image for the frontend service"
  type        = string
  default     = "vibakar/notes-app-frontend:v11"
}

variable "backend_image" {
  description = "Container image for the backend service"
  type        = string
  default     = "vibakar/notes-app-backend:latest"
}

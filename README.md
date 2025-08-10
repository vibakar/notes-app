# Full-Stack Notes App – Dockerized Setup

This project includes a **React frontend**, **Node.js backend**, and **PostgreSQL database**, all containerized using Docker Compose.

## 🐳 Services Overview

- **database**: PostgreSQL database with persistent volume.
- **backend**: Node.js server running on port `3000`.
- **frontend**: React app served on port `5173`.

---

## 🚀 Getting Started

### Clone the Repository

```bash
git clone https://github.com/vibakar/fullstack-app.git
cd fullstack-app
```

### Update .env file
Before starting the app, copy the example environment file and update it with your configuration

```cp .env.example .env```

### Start All Services
```docker-compose up --build```

### Access the App
`Frontend:` http://localhost:5173

`Backend API:` http://localhost:3000

`PostgreSQL DB:` localhost:5432


### Clean Up
To stop and remove all containers and volumes:

```docker-compose down -v```

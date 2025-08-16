### STAGE 1: Setup the environment & install dependencies ###
FROM node:24.4.0-bullseye-slim AS setup

RUN useradd -m app

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R app:app /app

USER app

EXPOSE 3000

### STAGE 2: Run the app in development mode ###
FROM setup AS dev
CMD ["npm", "run", "dev"]

### STAGE 3: Build the app for production ###
FROM setup AS prod
RUN npm run build
CMD ["npm", "run", "start"]

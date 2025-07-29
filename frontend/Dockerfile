### STAGE 1: Setup the environment & install dependencies ###
FROM node:21-alpine3.18 AS setup

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

### STAGE 2: Run the app in development mode ###
FROM setup AS development
CMD ["npm", "run", "dev"]

### STAGE 3: Build the app for production ###
FROM setup AS build
RUN npm run build

### STAGE 4: Serve the production app with a busybox web server ###
FROM busybox:latest

RUN adduser -D public
USER public
WORKDIR /public

COPY --from=build /app/dist /public

CMD ["busybox", "httpd", "-f", "-v", "-p", "5173"]

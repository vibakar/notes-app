FROM node:24.4.0-bullseye-slim

RUN useradd -m app

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R app:app /app

USER app

EXPOSE 3000

CMD ["npm", "run", "start"]

FROM node:20-bookworm

WORKDIR /app

COPY package*.json ./

RUN apt-get update && apt-get install -y python3 make g++ \
    && npm install --build-from-source

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
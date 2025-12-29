FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

# Expose port 8002 as referenced in server.js
EXPOSE 8002

CMD ["node", "server.js"]

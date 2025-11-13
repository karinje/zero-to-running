FROM node:18.12.0-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 4000

# Start server (nodemon in dev, node in prod)
CMD ["npm", "run", "dev"]


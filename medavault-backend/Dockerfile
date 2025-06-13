# Use Node.js LTS
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ postgresql-client

# Copy package files
COPY package*.json ./

# Install Node.js dependencies
RUN npm install --production

# Copy application code
COPY . .

# Set environment variables
ENV NODE_ENV=production
ENV PORT=9084

# Expose the application port
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD node healthcheck.js

# Start the application
CMD ["node", "server.js"]

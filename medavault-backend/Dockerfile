# Stage 1: Build stage
FROM node:18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY .npmrc ./

# Install all dependencies including devDependencies
RUN npm ci

# Copy application code
COPY . .

# Run any build steps if needed
# RUN npm run build

# =======================================
# Stage 2: Production stage
# =======================================
FROM node:18-alpine

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install runtime dependencies
RUN apk add --no-cache postgresql-client tzdata

# Set working directory
WORKDIR /app

# Copy built assets and production dependencies
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/ ./

# Set environment variables
ENV NODE_ENV=production
ENV PORT=9084
ENV TZ=UTC

# Create necessary directories with proper permissions
RUN mkdir -p /app/storage/images /app/storage/videos /app/storage/documents \
    && chown -R appuser:appgroup /app \
    && chmod -R 755 /app/storage

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD node healthcheck.js

# Start the application using node
CMD ["node", "server.js"]

# Optional: Use PM2 for process management in production
# RUN npm install -g pm2
# CMD ["pm2-runtime", "start", "server.js"]

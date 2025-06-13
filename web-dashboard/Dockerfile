# Stage 1: Build stage (if needed for frontend assets)
FROM node:18-alpine as builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source files
COPY . .

# Build the application (if needed)
# RUN npm run build

# ======================================
# Stage 2: Production stage
# ======================================
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy built files from builder
COPY --from=builder /app .

# Copy nginx configuration
COPY config/nginx/conf.d/dashboard-nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

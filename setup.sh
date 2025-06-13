#!/bin/bash

# Stop any running containers
echo "🛑 Stopping any running containers..."
docker-compose down

# Create necessary directories
echo "📂 Creating necessary directories..."
mkdir -p storage/{incoming,processed} logs config

# Build and start the services
echo "🚀 Building and starting services..."
docker-compose up --build -d

# Wait for services to initialize
echo "⏳ Waiting for services to initialize (30 seconds)..."
sleep 30

# Check service status
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "✅ Setup complete!"
echo ""
echo "Access the following services:"
echo "- WebDAV Server: http://localhost:8081"
echo "- FileStash Client: http://localhost:8082"
echo "- MedaVault Backend API: http://localhost:8084"
echo "- Web Dashboard: http://localhost:8085"
echo ""
echo "To view logs, run: docker-compose logs -f"

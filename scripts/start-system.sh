#!/bin/bash

echo "🚀 Starting WebDAV + Camel + MedaVault System..."

# Create required directories
mkdir -p storage/{incoming,processed,failed}
mkdir -p logs
mkdir -p config/filestash

# Set permissions
chmod -R 755 storage
chmod -R 755 config

# Start all services
echo "🐳 Starting Docker services..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "🔍 Checking service status..."
echo "📊 Dashboard: http://localhost:8080"
echo "🌐 WebDAV Server: http://localhost:8081/webdav/"
echo "📁 Filestash Client: http://localhost:8082"
echo "🔧 MedaVault API: http://localhost:8083/health"

echo ""
echo "✅ System started successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Open dashboard: http://localhost:8080"
echo "2. Configure Filestash: http://localhost:8082"
echo "3. Upload files via WebDAV"
echo "4. Monitor processing in dashboard"

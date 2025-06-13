#!/bin/bash

echo "🛑 Stopping WebDAV + Camel + MedaVault System..."

docker-compose down

echo "🧹 Cleaning up..."
docker system prune -f

echo "✅ System stopped successfully!"

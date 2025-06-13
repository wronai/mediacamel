#!/bin/bash

echo "📊 Monitoring system logs..."
echo "Press Ctrl+C to stop"

# Function to show logs with colors
show_logs() {
    echo "=== $1 ==="
    docker-compose logs --tail=10 "$2" | sed 's/^/  /'
    echo ""
}

while true; do
    clear
    echo "🔄 WebDAV + Camel + MedaVault System Logs - $(date)"
    echo "=================================================="

    show_logs "WebDAV Server" "webdav-server"
    show_logs "Camel Integration" "camel-integration"
    show_logs "MedaVault Backend" "medavault-backend"
    show_logs "Filestash Client" "filestash-client"

    sleep 10
done

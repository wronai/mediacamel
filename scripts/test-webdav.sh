#!/bin/bash

# Test WebDAV server connection
echo "Testing WebDAV server connection..."

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed."
    exit 1
fi

# Load environment variables
if [ -f ../.env ]; then
    export $(grep -v '^#' ../.env | xargs)
fi

# Test WebDAV connection
WEBDAV_URL="http://localhost:${WEBDAV_PORT_HTTP}"
echo "Connecting to WebDAV server at ${WEBDAV_URL}..."

# Perform a PROPFIND request to list root directory
RESPONSE=$(curl -s -X PROPFIND -u "${WEBDAV_USER}:${WEBDAV_PASSWORD}" "${WEBDAV_URL}" -H "Depth: 1")

if [ $? -eq 0 ]; then
    echo "✅ Successfully connected to WebDAV server!"
    echo "Available files/folders:"
    echo "$RESPONSE" | grep -oP '(?<=<d:href>).*?(?=</d:href>)' | grep -v "^/$"
else
    echo "❌ Failed to connect to WebDAV server"
    echo "Response: $RESPONSE"
    exit 1
fi

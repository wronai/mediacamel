#!/bin/bash

# Exit on error
set -e

# Source environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Set default values for environment variables if not set
: "${WEBDAV_HOST:=localhost}"
: "${WEBDAV_PORT_HTTP:=9081}"
: "${WEBDAV_PORT_HTTPS:=9443}"
: "${WEBDAV_STATUS_PORT:=9082}"
: "${WEBDAV_PATH:=/webdav}"
: "${BACKEND_HOST:=localhost}"
: "${BACKEND_PORT:=9084}"
: "${NGINX_WORKER_PROCESSES:=auto}"
: "${NGINX_WORKER_CONNECTIONS:=1024}"
: "${CLIENT_MAX_BODY_SIZE:=0}"

# Create nginx config directory if it doesn't exist
mkdir -p /etc/nginx/conf.d

# Function to replace environment variables in a file
replace_env_vars() {
    local input_file="$1"
    local output_file="$2"
    
    # Create a temporary file for the output
    local temp_file=$(mktemp)
    
    # Use envsubst to replace environment variables
    envsubst \
        "\$WEBDAV_HOST \
         \$WEBDAV_PORT_HTTP \
         \$WEBDAV_PORT_HTTPS \
         \$WEBDAV_STATUS_PORT \
         \$WEBDAV_PATH \
         \$BACKEND_HOST \
         \$BACKEND_PORT \
         \$NGINX_WORKER_PROCESSES \
         \$NGINX_WORKER_CONNECTIONS \
         \$CLIENT_MAX_BODY_SIZE" \
        < "$input_file" > "$temp_file"
    
    # Move the temporary file to the destination
    mv "$temp_file" "$output_file"
    
    # Set appropriate permissions
    chmod 644 "$output_file"
}

# Process each nginx config file
for config_file in /config/nginx/conf.d/*.conf; do
    if [ -f "$config_file" ]; then
        filename=$(basename "$config_file")
        echo "🔧 Processing $filename..."
        replace_env_vars "$config_file" "/etc/nginx/conf.d/$filename"
    fi
done

echo "✅ Nginx configuration generated successfully"

# Test nginx configuration
if nginx -t; then
    echo "✅ Nginx configuration test successful"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

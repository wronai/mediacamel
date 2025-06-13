#!/bin/sh
set -e

# Create WebDAV directory if it doesn't exist
mkdir -p /webdav

# Set ownership and permissions
chown -R nginx:nginx /webdav
chmod -R 755 /webdav

# Generate or update htpasswd file
if [ -n "$WEBDAV_USER" ] && [ -n "$WEBDAV_PASSWORD" ]; then
    htpasswd -b -c /etc/nginx/htpasswd "$WEBDAV_USER" "$WEBDAV_PASSWORD"
fi

# Start nginx
exec nginx -g 'daemon off;'

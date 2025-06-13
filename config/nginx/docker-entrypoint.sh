#!/bin/sh
set -e

# Create WebDAV directory if it doesn't exist
mkdir -p /webdav

# Set ownership and permissions
chown -R nginx:nginx /webdav
chmod -R 755 /webdav

# Create htpasswd file if it doesn't exist
if [ ! -f /etc/nginx/htpasswd ]; then
    touch /etc/nginx/htpasswd
    chmod 644 /etc/nginx/htpasswd
fi

# Generate or update htpasswd file
if [ -n "$WEBDAV_USER" ] && [ -n "$WEBDAV_PASSWORD" ]; then
    # Check if the user already exists in htpasswd
    if grep -q "^$WEBDAV_USER:" /etc/nginx/htpasswd; then
        # Update existing user
        htpasswd -b /etc/nginx/htpasswd "$WEBDAV_USER" "$WEBDAV_PASSWORD"
    else
        # Add new user
        htpasswd -b -c /etc/nginx/htpasswd "$WEBDAV_USER" "$WEBDAV_PASSWORD"
    fi
fi

# Fix permissions
chmod 644 /etc/nginx/htpasswd
chown nginx:nginx /etc/nginx/htpasswd

# Start nginx
exec nginx -g 'daemon off;'

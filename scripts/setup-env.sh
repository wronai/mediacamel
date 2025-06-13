#!/bin/bash

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "🔧 Creating .env file from .env.example"
    cp .env.example .env
    
    # Generate a random JWT secret if not set
    if grep -q "JWT_SECRET=your_jwt_secret_here" .env; then
        echo "🔑 Generating random JWT secret"
        JWT_SECRET=$(openssl rand -base64 32 | tr -d '\n' | tr -d ' ')
        sed -i "s/JWT_SECRET=your_jwt_secret_here/JWT_SECRET=${JWT_SECRET}/" .env
    fi
    
    # Set file permissions
    chmod 600 .env
    echo "✅ .env file created and secured"
else
    echo "ℹ️  .env file already exists, skipping creation"
fi

#!/bin/bash

echo "🧪 Testing WebDAV upload functionality..."

# Create test files
mkdir -p test-files
echo "This is a test document" > test-files/test-document.txt
echo "Test image content" > test-files/test-image.jpg
echo "Test video content" > test-files/test-video.mp4

# Test WebDAV upload using curl
echo "📤 Uploading test files to WebDAV..."

for file in test-files/*; do
    filename=$(basename "$file")
    echo "Uploading: $filename"

    curl -u webdav:medavault123 \
         -T "$file" \
         "http://localhost:8081/webdav/$filename"

    if [ $? -eq 0 ]; then
        echo "✅ Successfully uploaded: $filename"
    else
        echo "❌ Failed to upload: $filename"
    fi
done

echo ""
echo "🔍 Check the dashboard at http://localhost:8080 to see processed files"
echo "📁 Or browse WebDAV at http://localhost:8081/webdav/"

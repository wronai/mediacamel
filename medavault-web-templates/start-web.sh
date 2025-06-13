#!/bin/bash

echo "🌐 Starting MedaVault Web Templates..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install requirements
echo "📚 Installing requirements..."
pip install -r requirements.txt

# Create uploads directory
mkdir -p uploads

echo "🚀 Starting Flask application..."
echo ""
echo "📊 Web interfaces available at:"
echo "   - Administrator: http://localhost:5000/admin"
echo "   - Manager: http://localhost:5000/manager"
echo "   - External Client: http://localhost:5000/client"
echo ""
echo "🛑 To stop: Press Ctrl+C"

python app.py

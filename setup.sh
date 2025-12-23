#!/bin/bash
# AI Image Analysis - Setup Script
# Run this script to set up the complete system

echo "============================================"
echo "AI IMAGE ANALYSIS - SETUP SCRIPT"
echo "============================================"
echo ""

# Step 1: Database Migrations
echo "Step 1: Running Database Migrations..."
echo "----------------------------------------"
echo "Please run the following SQL files in PostgreSQL:"
echo ""
echo "psql -U postgres -d Health -f backend/migrations/2025_ai_analyzed_meals.sql"
echo "psql -U postgres -d Health -f backend/migrations/2025_water_intake_tracking.sql"
echo ""
read -p "Press Enter after running migrations..."

# Step 2: Backend Setup
echo ""
echo "Step 2: Installing Backend Dependencies..."
echo "----------------------------------------"
cd backend
if [ ! -d "node_modules" ]; then
    npm install
fi

# Check if form-data is installed
if ! npm list form-data > /dev/null 2>&1; then
    echo "Installing form-data..."
    npm install form-data
fi

echo "Backend dependencies installed!"

# Step 3: ChatbotAPI Setup
echo ""
echo "Step 3: Setting up ChatbotAPI (Python)..."
echo "----------------------------------------"
cd ../ChatbotAPI

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

echo "ChatbotAPI setup complete!"

# Step 4: Flutter Setup
echo ""
echo "Step 4: Setting up Flutter Project..."
echo "----------------------------------------"
cd ../Project

echo "Getting Flutter dependencies..."
flutter pub get

echo "Flutter setup complete!"

# Step 5: Environment Check
echo ""
echo "Step 5: Environment Check..."
echo "----------------------------------------"

# Check if .env files exist
if [ ! -f "../ChatbotAPI/.env" ]; then
    echo "⚠️  WARNING: ChatbotAPI/.env not found!"
    echo "Please create .env with GEMINI_API_KEY"
else
    echo "✅ ChatbotAPI/.env exists"
fi

if [ ! -f "../backend/.env" ]; then
    echo "⚠️  WARNING: backend/.env not found!"
else
    echo "✅ backend/.env exists"
fi

# Final Instructions
echo ""
echo "============================================"
echo "SETUP COMPLETE!"
echo "============================================"
echo ""
echo "To start the system, run these commands in separate terminals:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd backend"
echo "  npm start"
echo ""
echo "Terminal 2 (ChatbotAPI):"
echo "  cd ChatbotAPI"
echo "  source venv/bin/activate  # or venv\\Scripts\\activate on Windows"
echo "  python main.py"
echo ""
echo "Terminal 3 (Flutter):"
echo "  cd Project"
echo "  flutter run"
echo ""
echo "Backend will run on: http://localhost:60491"
echo "ChatbotAPI will run on: http://localhost:8000"
echo ""
echo "============================================"

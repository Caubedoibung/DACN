# AI IMAGE ANALYSIS - SETUP SCRIPT (Windows PowerShell)
# Run this script to set up the complete system

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "AI IMAGE ANALYSIS - SETUP SCRIPT" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Database Migrations
Write-Host "Step 1: Running Database Migrations..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host "Please run the following SQL files in PostgreSQL:"
Write-Host ""
Write-Host "psql -U postgres -d Health -f backend/migrations/2025_ai_analyzed_meals.sql" -ForegroundColor Green
Write-Host "psql -U postgres -d Health -f backend/migrations/2025_water_intake_tracking.sql" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter after running migrations"

# Step 2: Backend Setup
Write-Host ""
Write-Host "Step 2: Installing Backend Dependencies..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Set-Location backend

if (-not (Test-Path "node_modules")) {
    npm install
}

# Check if form-data is installed
$formDataInstalled = npm list form-data 2>&1 | Select-String "form-data@"
if (-not $formDataInstalled) {
    Write-Host "Installing form-data..." -ForegroundColor Cyan
    npm install form-data
}

Write-Host "Backend dependencies installed!" -ForegroundColor Green

# Step 3: ChatbotAPI Setup
Write-Host ""
Write-Host "Step 3: Setting up ChatbotAPI (Python)..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Set-Location ../ChatbotAPI

# Check if virtual environment exists
if (-not (Test-Path ".venv")) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Cyan
    python -m venv .venv
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Cyan
& .\.venv\Scripts\Activate.ps1

# Install dependencies
Write-Host "Installing Python dependencies..." -ForegroundColor Cyan
pip install -r requirements.txt

Write-Host "ChatbotAPI setup complete!" -ForegroundColor Green

# Deactivate venv for now
deactivate

# Step 4: Flutter Setup
Write-Host ""
Write-Host "Step 4: Setting up Flutter Project..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Set-Location ../Project

Write-Host "Getting Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host "Flutter setup complete!" -ForegroundColor Green

# Step 5: Environment Check
Write-Host ""
Write-Host "Step 5: Environment Check..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Check if .env files exist
if (-not (Test-Path "../ChatbotAPI/.env")) {
    Write-Host "⚠️  WARNING: ChatbotAPI/.env not found!" -ForegroundColor Red
    Write-Host "Please create .env with GEMINI_API_KEY" -ForegroundColor Red
} else {
    Write-Host "✅ ChatbotAPI/.env exists" -ForegroundColor Green
}

if (-not (Test-Path "../backend/.env")) {
    Write-Host "⚠️  WARNING: backend/.env not found!" -ForegroundColor Red
} else {
    Write-Host "✅ backend/.env exists" -ForegroundColor Green
}

# Back to root
Set-Location ..

# Final Instructions
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the system, run these commands in separate terminals:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Terminal 1 (Backend):" -ForegroundColor Cyan
Write-Host "  cd backend" -ForegroundColor White
Write-Host "  npm start" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 2 (ChatbotAPI):" -ForegroundColor Cyan
Write-Host "  cd ChatbotAPI" -ForegroundColor White
Write-Host "  .\.venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "  python main.py" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 3 (Flutter):" -ForegroundColor Cyan
Write-Host "  cd Project" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Backend will run on: http://localhost:60491" -ForegroundColor Magenta
Write-Host "ChatbotAPI will run on: http://localhost:8000" -ForegroundColor Magenta
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

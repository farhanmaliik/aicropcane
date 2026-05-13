$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Print-Header($text) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  AI Crop Cane - Setup and Start" -ForegroundColor Green
Write-Host ""

# Check Node.js
Print-Header "Checking Node.js"
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Node.js not found!" -ForegroundColor Red
    Write-Host "  Download from: https://nodejs.org" -ForegroundColor Yellow
    Write-Host "  Install it, then run this script again." -ForegroundColor Yellow
    Pause; return
}
Write-Host "[OK] Node.js $(node --version)" -ForegroundColor Green

# Check Python
Print-Header "Checking Python"
$pythonCmd = $null
$venvPython = "C:\mlservice-env\Scripts\python.exe"
if (Test-Path $venvPython) {
    $pythonCmd = $venvPython
} else {
    foreach ($cmd in @("python", "python3", "py")) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) { $pythonCmd = $cmd; break }
    }
}
if (-not $pythonCmd) {
    Write-Host "[ERROR] Python not found!" -ForegroundColor Red
    Write-Host "  Download from: https://www.python.org" -ForegroundColor Yellow
    Write-Host "  Check 'Add Python to PATH' during install, then run again." -ForegroundColor Yellow
    Pause; return
}
Write-Host "[OK] Python $(&$pythonCmd --version)" -ForegroundColor Green

# Check Flutter (optional)
$flutterCmd = $null
foreach ($p in @("flutter", "C:\flutter\bin\flutter.bat", "D:\flutter\bin\flutter.bat", "$env:USERPROFILE\flutter\bin\flutter.bat")) {
    if (Get-Command $p -ErrorAction SilentlyContinue) { $flutterCmd = $p; break }
}
if ($flutterCmd) {
    Write-Host "[OK] Flutter found" -ForegroundColor Green
} else {
    Write-Host "[--] Flutter not found - Flutter app will be skipped" -ForegroundColor Yellow
}

# Install Server packages
Print-Header "Installing Server packages"
Set-Location "$Root\server"
npm install
Write-Host "[OK] Done" -ForegroundColor Green

# Install Client packages
Print-Header "Installing Client packages"
Set-Location "$Root\client"
npm install
Write-Host "[OK] Done" -ForegroundColor Green

# Install Python packages
Print-Header "Installing Python ML packages"
Set-Location "$Root\ml-service"
& $pythonCmd -m pip install -r requirements.txt
Write-Host "[OK] Done" -ForegroundColor Green

# Flutter packages
if ($flutterCmd) {
    Print-Header "Getting Flutter packages"
    Set-Location "$Root\framerapp\framerapp"
    & $flutterCmd pub get
    Write-Host "[OK] Done" -ForegroundColor Green
}

# Kill ports
foreach ($port in @(5173, 3001, 8000, 8080)) {
    $pids = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -ErrorAction SilentlyContinue
    if ($pids) { Stop-Process -Id $pids -Force -ErrorAction SilentlyContinue }
}

# Launch all services
Print-Header "Starting all services"
Set-Location $Root

Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\server'; node index.js"
Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\client'; npm run dev"
Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\ml-service'; & '$pythonCmd' -m uvicorn app:app --port 8000"

if ($flutterCmd) {
    Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\framerapp\framerapp'; & '$flutterCmd' run -d chrome --release --web-port 8080"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  All services are starting!" -ForegroundColor Green
Write-Host "--------------------------------------------" -ForegroundColor Green
Write-Host "  React Web App  ->  http://localhost:5173" -ForegroundColor White
Write-Host "  Node.js Server ->  http://localhost:3001" -ForegroundColor White
Write-Host "  ML Service     ->  http://localhost:8000" -ForegroundColor White
if ($flutterCmd) {
    Write-Host "  Flutter App    ->  http://localhost:8080" -ForegroundColor White
}
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Wait 30 seconds then open: http://localhost:5173" -ForegroundColor Yellow
Write-Host ""
Pause
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$venvPython = "$Root\.venv\Scripts\python.exe"

# ML service uses system Python (has torch/fastapi installed there)
$systemPython = $null
foreach ($p in @("C:\Python313\python.exe", "C:\Python312\python.exe", "C:\Python311\python.exe")) {
    if (Test-Path $p) { $systemPython = $p; break }
}
if (-not $systemPython) { $systemPython = "python" }  # fallback to PATH

# Find Flutter
$flutterCmd = $null
foreach ($p in @("flutter","D:\flutter\bin\flutter.bat","C:\flutter\bin\flutter.bat","$env:USERPROFILE\flutter\bin\flutter.bat")) {
    if (Get-Command $p -ErrorAction SilentlyContinue) { $flutterCmd = $p; break }
}

# Free ports before starting
foreach ($port in @(5173, 3001, 8000, 8080)) {
    $pids = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -ErrorAction SilentlyContinue
    if ($pids) { Stop-Process -Id $pids -Force -ErrorAction SilentlyContinue }
}

Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\server'; node index.js"
Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\client'; npm run dev"
Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\ml-service'; & '$systemPython' -m uvicorn app:app --port 8000"
if ($flutterCmd) {
    Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-Command',"Set-Location '$Root\framerapp\framerapp'; & '$flutterCmd' run -d chrome --release --web-port 8080"
}

Write-Host ""
Write-Host "All services starting..." -ForegroundColor Green
Write-Host "  React Web App  -> http://localhost:5173"
Write-Host "  Flutter App    -> http://localhost:8080"
Write-Host "  Node.js Server -> http://localhost:3001"
Write-Host "  ML Service     -> http://localhost:8000"

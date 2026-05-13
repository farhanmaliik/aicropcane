@echo off
title AI Crop Cane - Setup and Start
echo.
echo  =============================================
echo   AI Crop Cane - Auto Setup and Start
echo  =============================================
echo.
echo  This will install all dependencies and start
echo  all services automatically. Please wait...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-and-start.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  [ERROR] Something went wrong. See above for details.
)
pause

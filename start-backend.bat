@echo off
cd /d "%~dp0backend"
echo Starting MovieMate backend on port 3000...
start /b npm start
timeout /t 2 /nobreak >nul
echo Setting up USB port forwarding for Android...
adb reverse tcp:3000 tcp:3000
echo.
echo Backend ready. Use test@gmail.com / Test123 to login.
echo Keep this window open while using the app.
pause

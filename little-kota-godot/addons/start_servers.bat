@echo off
REM Exit on error
setlocal enabledelayedexpansion
set ERRORS=0

REM Activate virtual environment
call py-venv\Scripts\activate.bat
if errorlevel 1 (
    echo Failed to activate virtual environment.
    exit /b 1
)

REM Run both scripts in parallel
start "" python godot-py-elevenlabs\elevenlabs_request_server.py
start "" python godot-py-stt\speech-to-text.py

REM Wait for user to close both processes manually
echo Scripts started. Press any key to exit this window...
pause >nul

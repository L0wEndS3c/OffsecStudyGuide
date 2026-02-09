REM Windows Installation
REM Created Feb 9, 2026
REM Author L0wEndS3c

@echo off
setlocal EnableExtensions EnableDelayedExpansion

cls
echo ==========================================
echo OffSec Learning MCP Server - Windows
echo ==========================================
echo.

REM Resolve script directory safely (no trailing slash)
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "SERVER_PATH=%SCRIPT_DIR%\server.py"

echo Install directory: %SCRIPT_DIR%
echo.

REM ------------------------------
REM Step 1: Check Python
REM ------------------------------
echo ==========================================
echo Step 1: Checking Python...
echo ==========================================

where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found.
    echo.
    echo Install Python 3 from:
    echo https://www.python.org/downloads/
    echo Make sure to check:
    echo   "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

for /f "delims=" %%P in ('where python') do (
    set "PYTHON_EXE=%%P"
    goto :python_found
)

:python_found
echo [OK] Using Python:
echo %PYTHON_EXE%
echo.

REM ------------------------------
REM Step 2: Check pip
REM ------------------------------
echo ==========================================
echo Step 2: Checking pip...
echo ==========================================

"%PYTHON_EXE%" -m pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip not available for this Python.
    echo Reinstall Python and ensure pip is included.
    echo.
    pause
    exit /b 1
)

echo [OK] pip available
echo.

REM ------------------------------
REM Step 3: Install MCP
REM ------------------------------
echo ==========================================
echo Step 3: Installing MCP...
echo ==========================================

"%PYTHON_EXE%" -m pip install --upgrade mcp
if errorlevel 1 (
    echo [ERROR] Failed to install MCP
    pause
    exit /b 1
)

echo [OK] MCP installed
echo.

REM ------------------------------
REM Step 4: Configure Claude
REM ------------------------------
echo ==========================================
echo Step 4: Configuring Claude Desktop...
echo ==========================================

set "CONFIG_DIR=%APPDATA%\Claude"
set "CONFIG_FILE=%CONFIG_DIR%\claude_desktop_config.json"

if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

REM Escape backslashes for JSON
set "SERVER_JSON=%SERVER_PATH:\=\\%"

(
echo {
echo   "mcpServers": {
echo     "offsec-learning": {
echo       "command": "python",
echo       "args": ["%SERVER_JSON%"]
echo     }
echo   }
echo }
) > "%CONFIG_FILE%"

echo [OK] Config written:
echo %CONFIG_FILE%
echo.

REM ------------------------------
REM Step 5: Verify server.py
REM ------------------------------
echo ==========================================
echo Step 5: Verifying server.py...
echo ==========================================

if not exist "%SERVER_PATH%" (
    echo [ERROR] server.py not found.
    echo Expected at:
    echo %SERVER_PATH%
    pause
    exit /b 1
)

echo [OK] server.py found
echo.

REM ------------------------------
REM Done
REM ------------------------------
echo ==========================================
echo Installation complete.
echo ==========================================
echo.
echo Restart Claude Desktop to apply changes.
echo.
pause
endlocal

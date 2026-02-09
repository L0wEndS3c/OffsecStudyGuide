@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo ==========================================
echo OffSec Learning MCP Server - Windows
echo ==========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "SERVER_PATH=%SCRIPT_DIR%server.py"

for %%P in (python python3) do (
    %%P --version >nul 2>&1 && set "PYTHON=%%P"
)
if not defined PYTHON (
    echo Python not found
    exit /b 1
)

%PYTHON% -m pip install --upgrade pip mcp || exit /b 1

set "CFG=%APPDATA%\Claude"
mkdir "%CFG%" 2>nul

set "SERVER_JSON=%SERVER_PATH:\=\\%"

(
echo {
echo  "mcpServers": {
echo    "offsec-learning": {
echo      "command": "%PYTHON%",
echo      "args": ["%SERVER_JSON%"]
echo    }
echo  }
echo }
) > "%CFG%\claude_desktop_config.json"

echo Installation complete. Restart Claude Desktop.
pause

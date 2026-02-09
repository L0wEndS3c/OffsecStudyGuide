@echo off
echo ==========================================
echo OffSec MCP Cleanup Utility (Windows)
echo ==========================================
echo.
echo This will close Claude Desktop and stop
echo any running MCP server processes.
echo.
pause

echo Closing Claude Desktop...
taskkill /F /IM claude.exe >nul 2>&1

echo Closing Python server processes...
taskkill /F /IM python.exe /FI "WINDOWTITLE eq server.py*" >nul 2>&1
taskkill /F /IM python3.exe /FI "WINDOWTITLE eq server.py*" >nul 2>&1

echo Waiting for file locks to release...
timeout /t 3 /nobreak >nul

echo.
echo Cleanup complete.
echo.
echo If deletion still fails, reboot and delete the folder.
echo.
pause

#!/bin/bash
# OffSec MCP Cleanup Utility – Kali Linux

set -e

echo "=========================================="
echo "OffSec MCP Cleanup Utility (Linux)"
echo "=========================================="
echo
echo "This will stop Claude Desktop and any"
echo "running OffSec MCP server processes."
echo

read -p "Press Enter to continue..."

echo
echo "Stopping Claude Desktop..."
pkill -f Claude 2>/dev/null || true

echo
echo "Stopping MCP server processes..."
pkill -f server.py 2>/dev/null || true

echo
echo "Waiting for file locks to release..."
sleep 3

echo
echo "Cleanup complete."
echo
echo "Optional manual cleanup:"
echo "- Remove virtualenv: rm -rf .venv"
echo "- Remove data: rm -rf ~/.offsec-mcp"
echo
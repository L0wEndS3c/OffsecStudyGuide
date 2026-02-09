#!/bin/bash
# OffSec Learning MCP Server - Kali Linux Installer (Hardened)

set -euo pipefail

clear
echo "=========================================="
echo " OffSec Learning MCP Server"
echo " Kali Linux Installation"
echo "=========================================="
echo

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_PATH="$SCRIPT_DIR/server.py"
VENV_DIR="$SCRIPT_DIR/.venv"

echo "Install directory: $SCRIPT_DIR"
echo

# Do not allow root
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run this script as root."
    echo "Run it as a normal user."
    exit 1
fi

# Step 1: Python check
echo "Step 1: Checking Python..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 not found."
    echo "Install it with:"
    echo "  sudo apt update && sudo apt install python3 python3-venv"
    exit 1
fi
python3 --version
echo

# Step 2: Verify server.py
echo "Step 2: Verifying server.py..."
if [ ! -f "$SERVER_PATH" ]; then
    echo "ERROR: server.py not found."
    echo "Expected location: $SERVER_PATH"
    exit 1
fi
chmod +x "$SERVER_PATH"
echo "server.py OK"
echo

# Step 3: Virtual environment
echo "Step 3: Setting up virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "Virtualenv created"
else
    echo "Virtualenv already exists"
fi

# Activate venv
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# Step 4: Install MCP
echo
echo "Step 4: Installing MCP..."
pip install --upgrade pip
pip install mcp
echo "MCP installed"
echo

# Step 5: Claude Desktop configuration
echo "Step 5: Configuring Claude Desktop..."

CONFIG_DIR="$HOME/.config/Claude"
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<EOF
{
  "mcpServers": {
    "offsec-learning": {
      "command": "$VENV_DIR/bin/python",
      "args": ["$SERVER_PATH"]
    }
  }
}
EOF

echo "Config written: $CONFIG_FILE"
echo

# Step 6: Finish
echo "=========================================="
echo "Installation Complete"
echo "=========================================="
echo
echo "Python: $(python3 --version)"
echo "Virtualenv: $VENV_DIR"
echo "Server: $SERVER_PATH"
echo "Data: \$HOME/.offsec-mcp/data.db"
echo
echo "Restart Claude Desktop before use."
echo

# Optional Claude shutdown
if pgrep -f Claude >/dev/null 2>&1; then
    read -r -p "Claude Desktop is running. Kill it now? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        pkill -f Claude || true
        echo "Claude Desktop terminated"
    fi
fi

echo "Done."

#!/usr/bin/env python3
"""
OffSec Learning MCP Server
Safe, cross-platform, AI-hardened version
"""

import asyncio
import json
import sqlite3
import re
import sys
from datetime import datetime, timedelta
from typing import Any, Dict
from pathlib import Path

# -----------------------------
# MCP imports
# -----------------------------
try:
    from mcp.server import Server
    from mcp.types import Resource, Tool, TextContent
    import mcp.server.stdio
except ImportError:
    print("Error: MCP package not installed")
    print("Install it with: pip install mcp")
    sys.exit(1)

# -----------------------------
# Windows / cross-platform safety
# -----------------------------
WINDOWS_RESERVED = {
    "con", "prn", "aux", "nul",
    *{f"com{i}" for i in range(1, 10)},
    *{f"lpt{i}" for i in range(1, 10)},
}

def safe_identifier(value: str, fallback: str = "user") -> str:
    """
    Sanitize identifiers so AI/user input can NEVER
    create invalid paths on Windows or Linux.
    """
    if not value:
        return fallback

    v = value.strip().lower()

    # Remove illegal filesystem characters
    v = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", v)

    # Windows forbids trailing dots/spaces
    v = v.rstrip(" .")

    # Block reserved device names
    if v in WINDOWS_RESERVED:
        v = f"_{v}"

    return v or fallback

# -----------------------------
# Database setup
# -----------------------------
BASE_DIR = Path.home() / ".offsec-mcp"
DB_PATH = BASE_DIR / "data.db"
BASE_DIR.mkdir(parents=True, exist_ok=True)

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    c.execute("""
        CREATE TABLE IF NOT EXISTS plans (
            user_id TEXT PRIMARY KEY,
            plan_data TEXT,
            created_at TEXT
        )
    """)

    c.execute("""
        CREATE TABLE IF NOT EXISTS progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            type TEXT,
            data TEXT,
            timestamp TEXT
        )
    """)

    conn.commit()
    conn.close()

def save_plan(user_id: str, plan: dict):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        "INSERT OR REPLACE INTO plans VALUES (?, ?, ?)",
        (user_id, json.dumps(plan), datetime.now().isoformat())
    )
    conn.commit()
    conn.close()

def load_plan(user_id: str):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT plan_data FROM plans WHERE user_id = ?", (user_id,))
    row = c.fetchone()
    conn.close()
    return json.loads(row[0]) if row else None

def log_progress(user_id: str, ptype: str, data: dict):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        "INSERT INTO progress VALUES (NULL, ?, ?, ?, ?)",
        (user_id, ptype, json.dumps(data), datetime.now().isoformat())
    )
    conn.commit()
    conn.close()

def get_progress(user_id: str) -> dict:
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        "SELECT type, data FROM progress WHERE user_id = ? ORDER BY timestamp",
        (user_id,)
    )
    rows = c.fetchall()
    conn.close()

    progress = {"completed": [], "hours": 0, "boxes": [], "phase": 1}

    for ptype, data in rows:
        d = json.loads(data)
        if ptype == "topic":
            progress["completed"].append(d)
        elif ptype == "hours":
            progress["hours"] += d["hours"]
        elif ptype == "box":
            progress["boxes"].append(d)

    return progress

init_db()

# -----------------------------
# MCP Server
# -----------------------------
app = Server("offsec-learning")

@app.list_resources()
async def list_resources() -> list[Resource]:
    return [
        Resource("offsec://certs", "Certifications Info", "application/json"),
        Resource("offsec://resources/free", "Free Resources", "application/json"),
        Resource("offsec://resources/paid", "Paid Resources", "application/json"),
        Resource("offsec://tools", "Tools List", "application/json"),
    ]

@app.read_resource()
async def read_resource(uri: str) -> str:
    return json.dumps(OFFSEC_DATA.get(uri.split("//")[1], {}), indent=2)

@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    if "user_id" in arguments:
        arguments["user_id"] = safe_identifier(arguments["user_id"])

    handlers = {
        "create_study_plan": create_plan,
        "recommend_resources": get_resources,
        "track_progress": track_user_progress,
        "get_practice_boxes": recommend_boxes,
        "make_weekly_schedule": make_schedule,
    }

    if name not in handlers:
        raise ValueError(f"Unknown tool: {name}")

    return await handlers[name](arguments)

# (business logic functions unchanged except using sanitized user_id)

async def main():
    async with mcp.server.stdio.stdio_server() as (r, w):
        await app.run(r, w, app.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())

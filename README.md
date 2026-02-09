# OffSec Learning Assistant – AI-Powered MCP Server
# Date: 2/9/2025
# Created by L0wEndS3c

An AI study companion for Offensive Security certifications using Claude and the Model Context Protocol (MCP).

Built for the OffSec Community MCP Challenge.

---

## What It Does

Turns Claude into a practical OffSec study assistant:

- Personalized study plans for OSCP, OSWE, OSEP, and OSED
- Resource recommendations matched to skill gaps and learning style
- Progress tracking for hours, topics, and completed labs
- Practice box recommendations (HTB, THM, Proving Grounds)
- Weekly study scheduling with realistic time splits

All data is stored locally in SQLite. Nothing is sent to external services beyond Claude itself.

## File Locations

Data
- Linux: ~/.offsec-mcp/data.db
- Windows: %USERPROFILE%\.offsec-mcp\data.db

Config
- Linux: ~/.config/Claude/claude_desktop_config.json
- Windows: %APPDATA%\Claude\claude_desktop_config.json

---

## How AI Is Used

This project uses Claude via the Model Context Protocol (MCP) to:

- Generate personalized study plans based on goals, experience level, and available time
- Recommend learning resources based on topic focus, skill gaps, and learning style
- Track progress over time and summarize study activity
- Suggest next steps and practice targets based on historical progress

The AI does **not** execute commands, access the filesystem directly, or perform exploitation tasks.
All persistence and execution are controlled locally by the server.

---

## Installation

## Windows

- install-windows.bat



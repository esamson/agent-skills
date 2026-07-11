#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
CURSOR_DIR="$HOME/.cursor"

echo "BASE_DIR: $BASE_DIR"
echo "CURSOR_DIR: $CURSOR_DIR"

rsync -av "$BASE_DIR/agents/" "$CURSOR_DIR/agents/"
rsync -av "$BASE_DIR/skills/" "$CURSOR_DIR/skills/agent-skills/"
rsync -av "$BASE_DIR/.claude/commands/" "$CURSOR_DIR/commands/"
rsync -av "$BASE_DIR/references/" "$CURSOR_DIR/references/"
rsync -av "$BASE_DIR/hooks/" "$CURSOR_DIR/hooks/"
cp "$BASE_DIR/hooks/cursor.json" "$CURSOR_DIR/hooks.json"

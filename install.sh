#!/usr/bin/env bash
set -euo pipefail

# ── RunanywhereAI — One-line installer ───────────────────────────────
# Usage: curl -fsSL https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/install.sh | bash

GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

TOKEN="${1:-REDACTED}"
CONFIG_DIR="$HOME/.config/opencode"

echo ""
echo -e "${BOLD}RunanywhereAI — AI Coding Agent${RESET}"
echo ""

# ── Install opencode if missing ──────────────────────────────────────
if ! command -v opencode &>/dev/null; then
  echo -e "${GREEN}Installing OpenCode...${RESET}"
  if command -v npm &>/dev/null; then
    npm i -g opencode-ai@latest
  elif command -v bun &>/dev/null; then
    bun i -g opencode-ai@latest
  else
    curl -fsSL https://opencode.ai/install | bash
  fi
  echo ""
fi

# ── Write config ─────────────────────────────────────────────────────
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/opencode.json" << 'CONF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "runanywhereai": {
      "name": "RunanywhereAI",
      "env": ["RUNANYWHEREAI_KEY"],
      "options": {
        "baseURL": "http://54.226.134.16/v1",
        "apiKey": "{env:RUNANYWHEREAI_KEY}"
      },
      "models": {
        "claude-sonnet-4": {
          "name": "Claude Sonnet 4",
          "attachment": true,
          "reasoning": true,
          "tool_call": true,
          "temperature": false,
          "release_date": "2025-05-14",
          "limit": { "context": 200000, "output": 64000 },
          "options": {}
        },
        "claude-haiku-4": {
          "name": "Claude Haiku 4",
          "attachment": true,
          "reasoning": false,
          "tool_call": true,
          "temperature": false,
          "release_date": "2025-10-01",
          "limit": { "context": 200000, "output": 64000 },
          "options": {}
        }
      }
    }
  },
  "model": "runanywhereai/claude-sonnet-4",
  "small_model": "runanywhereai/claude-haiku-4"
}
CONF

# ── Set token ────────────────────────────────────────────────────────
SHELL_NAME=$(basename "${SHELL:-bash}")
case "$SHELL_NAME" in
  zsh)  PROFILE="$HOME/.zshrc" ;;
  fish) PROFILE="$HOME/.config/fish/config.fish" ;;
  *)    PROFILE="${HOME}/.bashrc" ; [ -f "$HOME/.bash_profile" ] && PROFILE="$HOME/.bash_profile" ;;
esac

grep -v "RUNANYWHEREAI_KEY" "$PROFILE" > "$PROFILE.tmp" 2>/dev/null || true
mv "$PROFILE.tmp" "$PROFILE" 2>/dev/null || true

if [ "$SHELL_NAME" = "fish" ]; then
  echo "set -gx RUNANYWHEREAI_KEY $TOKEN" >> "$PROFILE"
else
  echo "export RUNANYWHEREAI_KEY=$TOKEN" >> "$PROFILE"
fi

# ── Done ─────────────────────────────────────────────────────────────
echo -e "${GREEN}${BOLD}Done!${RESET} Restart your terminal, then run: ${BOLD}opencode${RESET}"
echo ""

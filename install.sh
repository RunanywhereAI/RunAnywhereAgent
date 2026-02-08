#!/usr/bin/env bash
set -euo pipefail

# ── RunanywhereAI — One-line installer ───────────────────────────────
# Usage: curl -fsSL https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/install.sh | bash -s -- YOUR_TOKEN
# Or:    bash install.sh YOUR_TOKEN

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

TOKEN="${1:-}"
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
[ -f "$CONFIG_DIR/opencode.json" ] && cp "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.bak" 2>/dev/null

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
if [ -z "$TOKEN" ]; then
  echo -e "${BOLD}Enter your RunanywhereAI token:${RESET}"
  read -rp "  Token: " TOKEN
  [ -z "$TOKEN" ] && { echo -e "${RED}No token. Set it later: export RUNANYWHEREAI_KEY=your-token${RESET}"; exit 1; }
fi

SHELL_NAME=$(basename "${SHELL:-bash}")
case "$SHELL_NAME" in
  zsh)  PROFILE="$HOME/.zshrc" ;;
  fish) PROFILE="$HOME/.config/fish/config.fish" ;;
  *)    PROFILE="${HOME}/.bashrc" ; [ -f "$HOME/.bash_profile" ] && PROFILE="$HOME/.bash_profile" ;;
esac

# Remove old entry, add new
grep -v "RUNANYWHEREAI_KEY" "$PROFILE" > "$PROFILE.tmp" 2>/dev/null || true
mv "$PROFILE.tmp" "$PROFILE" 2>/dev/null || true

if [ "$SHELL_NAME" = "fish" ]; then
  echo "set -gx RUNANYWHEREAI_KEY $TOKEN" >> "$PROFILE"
else
  echo "export RUNANYWHEREAI_KEY=$TOKEN" >> "$PROFILE"
fi
export RUNANYWHEREAI_KEY="$TOKEN"

# ── Done ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}Done!${RESET} Run ${BOLD}opencode${RESET} in any project to start coding."
echo -e "  (Restart your terminal or run: source $PROFILE)"
echo ""

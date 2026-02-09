#!/usr/bin/env bash
set -euo pipefail

# ── RunanywhereAI — One-line installer ───────────────────────────────
# Usage: curl -fsSL https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/install.sh | bash

GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_URL="https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/opencode.json"

echo ""
echo -e "${BOLD}RunanywhereAI — AI Coding Agent${RESET}"
echo ""

# ── Get token from argument or prompt ─────────────────────────────
TOKEN="${1:-}"
if [ -z "$TOKEN" ]; then
  echo -n "Paste your access token: "
  read -r TOKEN
  if [ -z "$TOKEN" ]; then
    echo "ERROR: Token is required. Get one from your hackathon organizer."
    exit 1
  fi
fi

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

# ── Write config (download from repo) ────────────────────────────────
mkdir -p "$CONFIG_DIR"
curl -fsSL "$CONFIG_URL" -o "$CONFIG_DIR/opencode.json"

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

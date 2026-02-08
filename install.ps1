# ── RunanywhereAI — Windows One-Line Installer ──────────────────────
# Usage: irm https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$Token = "REDACTED"

Write-Host "`nRunanywhereAI — AI Coding Agent`n" -ForegroundColor Cyan

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Host "Installing OpenCode..." -ForegroundColor Green
    if (Get-Command npm -ErrorAction SilentlyContinue) { npm i -g opencode-ai@latest }
    else { Write-Host "Install Node.js from https://nodejs.org first." -ForegroundColor Red; exit 1 }
}

$dir = Join-Path $env:USERPROFILE ".config\opencode"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

@'
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
'@ | Set-Content -Path (Join-Path $dir "opencode.json") -Encoding UTF8

$env:RUNANYWHEREAI_KEY = $Token
[System.Environment]::SetEnvironmentVariable("RUNANYWHEREAI_KEY", $Token, "User")

Write-Host "`nDone! Open a NEW terminal and run: opencode`n" -ForegroundColor Green

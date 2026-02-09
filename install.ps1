# ── RunanywhereAI — Windows One-Line Installer ──────────────────────
# Usage: irm https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$Token = "REDACTED"
$ConfigUrl = "https://raw.githubusercontent.com/RunanywhereAI/RunAnywhereAgent/main/opencode.json"

Write-Host "`nRunanywhereAI — AI Coding Agent`n" -ForegroundColor Cyan

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Host "Installing OpenCode..." -ForegroundColor Green
    if (Get-Command npm -ErrorAction SilentlyContinue) { npm i -g opencode-ai@latest }
    else { Write-Host "Install Node.js from https://nodejs.org first." -ForegroundColor Red; exit 1 }
}

$dir = Join-Path $env:USERPROFILE ".config\opencode"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
Invoke-WebRequest -Uri $ConfigUrl -OutFile (Join-Path $dir "opencode.json")

$env:RUNANYWHEREAI_KEY = $Token
[System.Environment]::SetEnvironmentVariable("RUNANYWHEREAI_KEY", $Token, "User")

Write-Host "`nDone! Open a NEW terminal and run: opencode`n" -ForegroundColor Green

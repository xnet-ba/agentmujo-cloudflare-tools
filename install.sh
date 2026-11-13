#!/usr/bin/env bash
# install.sh — install AgentMujoCloudflareTools on ANY OpenCode agent. Idempotent.
# Usage: ./install.sh [--home DIR] | ./install.sh --check
# Does: copy skill -> skills dir, cf-pages.sh -> opencode scripts dir. No secrets, no MCP.
set -u
REPO="$(cd "$(dirname "$0")" && pwd)"

doctor() {
  local fail=0
  for c in node npx git; do
    if command -v "$c" >/dev/null; then echo "OK   $c"; else echo "MISS $c (required)"; fail=1; fi
  done
  return $fail
}
[ "${1:-}" = "--check" ] && { doctor; exit $?; }
doctor >/dev/null || { echo "missing requirements (--check for details)"; exit 1; }
HOME_DIR="${1:-$HOME}"
[ "${1:-}" = "--home" ] && HOME_DIR="${2:-$HOME}"
SKILLS_DIR="$HOME_DIR/.config/opencode/skills"
SCRIPTS_DIR="$HOME_DIR/.config/opencode/scripts"

mkdir -p "$SKILLS_DIR/agentmujo-cloudflare-tools" "$SCRIPTS_DIR"
if [ -f "$SKILLS_DIR/agentmujo-cloudflare-tools/SKILL.md" ] && diff -q "$REPO/skills/agentmujo-cloudflare-tools/SKILL.md" "$SKILLS_DIR/agentmujo-cloudflare-tools/SKILL.md" >/dev/null; then
  echo "skip skill (identical)"
else
  cp "$REPO/skills/agentmujo-cloudflare-tools/SKILL.md" "$SKILLS_DIR/agentmujo-cloudflare-tools/SKILL.md" && echo "skill agentmujo-cloudflare-tools"
fi
if [ -f "$SCRIPTS_DIR/cf-pages.sh" ] && diff -q "$REPO/scripts/cf-pages.sh" "$SCRIPTS_DIR/cf-pages.sh" >/dev/null; then
  echo "skip cf-pages.sh (identical)"
else
  cp "$REPO/scripts/cf-pages.sh" "$SCRIPTS_DIR/cf-pages.sh" && chmod +x "$SCRIPTS_DIR/cf-pages.sh" && echo "script cf-pages.sh"
fi
echo "done. Set CLOUDFLARE_API_TOKEN + CLOUDFLARE_ACCOUNT_ID, then: cf-pages.sh <dir> <project-name>"

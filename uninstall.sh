#!/usr/bin/env bash
# uninstall.sh — remove AgentMujoCloudflareTools. Does NOT touch tokens, projects or deployments.
set -u
HOME_DIR="${1:-$HOME}"
[ "${1:-}" = "--home" ] && HOME_DIR="${2:-$HOME}"
rm -rf "$HOME_DIR/.config/opencode/skills/agentmujo-cloudflare-tools"
rm -f "$HOME_DIR/.config/opencode/scripts/cf-pages.sh"
echo "removed (Cloudflare projects/deployments untouched)"

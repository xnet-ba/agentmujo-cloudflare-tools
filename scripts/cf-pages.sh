#!/usr/bin/env bash
# cf-pages.sh — free deploy of a static site to <project>.pages.dev (Cloudflare Pages).
# Auth: export CLOUDFLARE_API_TOKEN + CLOUDFLARE_ACCOUNT_ID (headless),
# or `npx wrangler login` once (interactive). Optional convention: tokens in
# ~/.secrets/cloudflare and ~/.secrets/cloudflare_account_id (chmod 600) are picked up automatically.
# Why wrangler and not cf: the cf CLI has no legacy Pages direct-upload; *.pages.dev needs Pages projects.
# For new Worker-based sites (*.workers.dev) use `cf deploy <dir>` instead.
# Usage: cf-pages.sh <dir> <project-name>
set -euo pipefail
DIR="${1:-}"; PROJ="${2:-}"
if [[ -z "$DIR" || -z "$PROJ" ]]; then echo "Usage: $0 <dir> <project-name>"; exit 1; fi
[[ -d "$DIR" ]] || { echo "No such dir: $DIR"; exit 1; }
if [[ -z "${CLOUDFLARE_API_TOKEN:-}" && -f "$HOME/.secrets/cloudflare" ]]; then
  CLOUDFLARE_API_TOKEN="$(cat "$HOME/.secrets/cloudflare")"; export CLOUDFLARE_API_TOKEN
fi
if [[ -z "${CLOUDFLARE_ACCOUNT_ID:-}" && -f "$HOME/.secrets/cloudflare_account_id" ]]; then
  CLOUDFLARE_ACCOUNT_ID="$(cat "$HOME/.secrets/cloudflare_account_id")"; export CLOUDFLARE_ACCOUNT_ID
fi
if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "Set CLOUDFLARE_API_TOKEN (or run: npx wrangler login)"; exit 1
fi
# shortcut: direct asset upload, no D1/KV/R2; split deploys bigger than the free limits.
# --force only when creating a NEW project (legacy Pages directly, no workers.dev subdomain needed).
if ! npx -y wrangler pages project list 2>/dev/null | grep -q "│ ${PROJ} "; then
  npx -y wrangler pages project create "$PROJ" --production-branch=main --force
fi
npx -y wrangler pages deploy "$DIR" --project-name="$PROJ"
echo "Done: https://${PROJ}.pages.dev"

---
name: agentmujo-cloudflare-tools
description: Free Cloudflare workflows for AI agents — static sites to *.pages.dev (Pages), safe public URLs for local services (Tunnel + Access), and dead-simple uptime monitoring (Workers cron). Use when the user asks to deploy/publish a static site, expose a localhost service, or add a healthcheck.
---

# AgentMujoCloudflareTools

Three free-tier Cloudflare workflows. Everything runs on the Cloudflare free plan; no credit card, no server.

## Auth (all three workflows)

```bash
export CLOUDFLARE_API_TOKEN="<token>"      # dash → My Profile → API Tokens
export CLOUDFLARE_ACCOUNT_ID="<account>"   # 32 hex chars, dashboard sidebar
```

Token scopes needed: **Account / Cloudflare Pages / Edit** (workflow 1), **Account / Argo Tunnel / Edit** (workflow 2), **Account / Workers Scripts / Edit** (workflow 3). Verify once: `cf auth whoami` or `wrangler whoami`. Headless servers: token env beats browser login.

## 1. pages-deploy — static folder → https://NAME.pages.dev

**Decide first:** `*.pages.dev` domain wanted → this workflow (Wrangler, legacy Pages direct-upload). New Worker app / `*.workers.dev` fine → `cf deploy <dir>` instead (`cf` CLI has no legacy Pages support).

Free limits: unlimited sites and requests; 25 MB max per file.

```bash
cf-pages.sh <dir> <project-name>   # e.g. cf-pages.sh ./dist moj-sajt
```

What the script does: creates the Pages project on first run (legacy Pages directly, no workers.dev subdomain needed), deploys on later runs. Staging convention: `<site>-staging` for previews, plain `<site>` for production. Cleanup: `wrangler pages project delete <project-name>`.

If deploying by hand: `wrangler pages project create <name> --production-branch=main --force` once, then `wrangler pages deploy <dir> --project-name=<name>` (no `--force` on existing projects).

## 2. tunnel-expose — localhost service → safe public URL (no open ports)

Never expose dev servers with bare `python3 -m http.server` / direct ports. Two options:

- **Quick (try-out, minutes):** `cloudflared tunnel --url http://localhost:PORT` → random `*.trycloudflare.com` URL. Dies with the command; good for one preview.
- **Named (stable):** `cloudflared tunnel login` (once) → `cloudflared tunnel create <name>` → route DNS `cloudflared tunnel route dns <name> <host>` → run `cloudflared tunnel run <name>` (systemd for persistence).
- **Lock it:** put Cloudflare Access (Zero Trust) in front — free up to 50 users — so only your login reaches the service. Verify the local port is NOT publicly reachable afterwards (`curl` the public IP:port must fail).

## 3. workers-cron-health — uptime monitoring without a monitoring server

A Scheduled Worker pings your URLs and alerts (email via MailChannels free, or Telegram bot API):

```ts
export default {
  // wrangler.jsonc: { "triggers": { "crons": ["*/5 * * * *"] } }
  async scheduled(_e, env) {
    for (const u of (env.TARGETS as string).split(",")) {
      const r = await fetch(u, { redirect: "follow" });
      if (!r.ok) await fetch(`https://api.telegram.org/bot${env.BOT}/sendMessage`, {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ chat_id: env.CHAT, text: `DOWN ${u}: ${r.status}` }),
      });
    }
  },
};
```

Deploy: `wrangler deploy`. Secrets via `wrangler secret put BOT`. Logs: `wrangler tail`.

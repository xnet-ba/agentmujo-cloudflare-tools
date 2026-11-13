# AgentMujoCloudflareTools

Free Cloudflare workflows for OpenCode AI agents. One skill, three jobs:

1. **pages-deploy** — static folder → `https://NAME.pages.dev` (free, unlimited sites)
2. **tunnel-expose** — localhost service → safe public URL, no open ports (Tunnel + Access)
3. **workers-cron-health** — uptime monitoring with a Scheduled Worker, no monitoring server

No private data inside: auth is your own `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` (env or `wrangler login`). Nothing here phones home.

## Install (any OpenCode)

```bash
git clone https://github.com/xnet-ba/agentmujo-cloudflare-tools.git
cd agentmujo-cloudflare-tools
./install.sh --check   # preflight, optional
./install.sh           # skill + cf-pages.sh, idempotent
```

Needs: `node`, `npx`, `git` (wrangler runs via `npx -y wrangler`, no global install).
Cloudflare account: free plan is enough. Token scopes: Pages Edit (1), Argo Tunnel Edit (2), Workers Scripts Edit (3).

```bash
export CLOUDFLARE_API_TOKEN="<token>"
export CLOUDFLARE_ACCOUNT_ID="<32-hex-account-id>"
cf-pages.sh <dir> <project-name>   # → https://<project-name>.pages.dev
```

Uninstall: `./uninstall.sh` (removes skill + script only; Cloudflare projects untouched).

## Layout

```
skills/agentmujo-cloudflare-tools/SKILL.md  # the skill (3 workflows)
scripts/cf-pages.sh                          # pages.dev deploy helper
install.sh / uninstall.sh                    # idempotent installer
```

## License

MIT — see LICENSE.

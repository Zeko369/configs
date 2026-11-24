# Mac credentials for the Linux development host

Run the transfer on your Mac, where your existing accounts are signed in. Python 3.11+ and SSH are required. The script inventories a fixed set of credential files and environment variables, sends available selected entries over SSH, and installs them on Linux with mode 600. It keeps the bundle in memory on the Mac. Existing Linux files are backed up under `~/.local/state/configs/mac-import/`.

```sh
transfer_dir="$(mktemp -d)"
scp ubuntu@100.90.160.94:/home/ubuntu/repos/configs/bin/configs-export-mac-credentials "$transfer_dir/transfer.py"
python3 "$transfer_dir/transfer.py" --send
```

Use your usual SSH host alias with `--host HOST` if needed. To inspect names without transferring anything, omit `--send`. Use `--only atuin,doctl,kube,env` to choose specific categories. The output contains names and status messages; it is safe to return that output to the setup session.

## Accounts and private files

- **1Password:** Mac biometric/Keychain sessions are not copied. An existing `OP_SERVICE_ACCOUNT_TOKEN` in the Mac shell is transferred. You can also read an existing token with `--op-token-ref 'op://VAULT/ITEM/FIELD'`, enter it locally with `--op-token`, or create a token using the command below. For personal account access, this Linux host also has `op-remote setup`; run it in your own SSH terminal to enter the account password and Secret Key privately. Organization SSO/MFA policies still apply.
- **Atuin:** Copies the existing encryption key and session, respecting configured `key_path` and `session_path`. It preserves the Linux history database. After validation, run `atuin sync` to fetch the Mac history. If there is no portable session, use `atuin login --username YOUR_USERNAME` in your own terminal. Do not generate a replacement encryption key for existing synced history.
- **DigitalOcean:** Copies the doctl config and removes a stale Mac `config:` path. Existing shell tokens are included. If missing or expired, run `doctl auth init`.
- **Kubernetes:** Exports merged kubeconfig with certificates and keys embedded using `kubectl config view --raw --flatten`. Contexts are copied without contacting clusters. External authentication helpers and Mac-only `exec` paths may need additional setup on Linux.
- **Vercel:** Copies portable auth and global settings from Mac Application Support or XDG locations. If the token is stored only in Keychain, use `vercel login` on Linux.
- **Railway:** Copies `~/.railway/config.json` and selected shell tokens. Mac project directory links may need `railway link` in the corresponding Linux checkout. If authentication is missing or expired, use `railway login --browserless`.
- **Pulumi:** Copies plaintext CLI credentials or an existing `PULUMI_ACCESS_TOKEN`. Encrypted credential envelopes are skipped; use `pulumi login` when needed. Provider credentials and stack passphrases are separate from the Pulumi account login.
- **Graphite:** Copies the default user config and recognized auth files. Additional profiles or Keychain-only tokens may require `gt auth` on Linux.
- **WakaTime:** Copies `.wakatime.cfg` and an existing shell API key.
- **rclone:** Copies `rclone.conf`. Remote OAuth tokens still need validation; local paths may need adjustment.
- **Cloudflare:** Copies cloudflared's account certificate and tunnel credential JSON files. Tunnel settings are staged for review. It does not start tunnels.
- **SOPS/age:** Copies existing age identities or an existing `SOPS_AGE_KEY`. New identities would not decrypt your existing encrypted files.
- **API environment values:** Only `OP_SERVICE_ACCOUNT_TOKEN`, `DIGITALOCEAN_ACCESS_TOKEN`, `DO_API_TOKEN`, `VERCEL_TOKEN`, `RAILWAY_API_TOKEN`, `RAILWAY_TOKEN`, `PULUMI_ACCESS_TOKEN`, `WAKATIME_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, and `SOPS_AGE_KEY` are included when present. Linux loads them through `.zshenv`. Other variables and unexported shell values need separate review.
- **Private machine settings:** Copies the Mac repo's `local/zshrc`, `local/gitconfig`, `local/tmux.conf`, and global mise config into an ignored review directory. These files are not automatically sourced or applied.
- **Project secrets:** Add an explicit `--project-env ~/path/to/project/.env` for each project file to stage for review. These files are not automatically applied to a Linux project.

GitHub, Codex, and Tailscale are already authenticated on Linux. The script excludes their sessions, SSH private keys, `authorized_keys`, entire Keychains, and general shell history. Git signing is a separate setup step; a host-specific signing key can be registered without copying the Mac private key.

## Create a 1Password service account

Replace `YOUR_SHARED_VAULT` with the actual vault name. Repeat `--op-vault` to allow another vault. The Mac CLI must be signed in as a user permitted to create service accounts.

```sh
python3 "$transfer_dir/transfer.py" --send --only env \
  --create-op-service-account --op-vault 'YOUR_SHARED_VAULT'
```

This creates a service account named `dev-linux-configs`, grants read-only access to the selected vaults, sets a 90-day expiry, saves the token as a concealed 1Password item in the first vault, and transfers it to Linux. If saving the item fails, a mode-600 recovery copy is retained on the Mac and its path is printed. Rotate or renew the token before it expires. Built-in Personal, Private, and Employee vaults cannot be granted to a service account. See [1Password service-account creation](https://www.1password.dev/cli/reference/management-commands/service-account).

The script gathers existing provider credentials and can create the scoped 1Password token. Other providers issue their own tokens and certificates; a local script cannot manufacture valid credentials for all accounts.

## After transfer

The Linux receiver writes `~/.local/state/configs/mac-import/latest-import.json` with installed paths, the review directory, and backup location. Open a new Zsh shell to load environment tokens. Account credentials must then be validated with read-only identity commands. Kubernetes contexts should first be reviewed locally; importing a context does not authorize deployment or production changes.

## Linux databases

This host now uses PostgreSQL 18.6 and Valkey 9.1.2 in the machine-local Compose project `configs-services`, with persistent volumes and restart policies. They bind to localhost ports 5432 and 6379. PostgreSQL's matching `psql`/`pg_dump` client is installed; `valkey-cli` uses the matching container client.

```sh
configs-services ps
configs-services up -d
psql --version
valkey-cli PING
```

Use `configs-services` for these servers. Unidy's old `docker-compose.deps.yml` still selects the previous images and should not be started on these same ports.

All 12 databases, 1,363 tables, 7,360 table rows, column definitions, sequences, and extensions passed comparison after the migration. Valkey's 34 keys across seven databases passed value comparisons. Rails and Sidekiq reconnected, and `/logins` returned HTTP 200 with browser headers.

Private migration backups are under `~/.local/state/configs/database-upgrade/20261011T112148Z/`. The original `unidy-deps-postgres-1` and `unidy-deps-valkey-1` containers remain stopped, with their original volumes intact. Rolling back to them restores the pre-upgrade state, so first save any subsequent changes on the new servers.

Latest stable versions were checked against [PostgreSQL releases](https://www.postgresql.org/docs/release/) and [Valkey downloads](https://valkey.io/download/). PostgreSQL 18 uses the [new Docker volume layout](https://hub.docker.com/_/postgres). The native client comes from the [official PostgreSQL Ubuntu repository](https://www.postgresql.org/download/linux/ubuntu/).

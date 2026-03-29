# nauvoo

Production homelab server running all self-hosted services via Podman Quadlet containers.

## Hardware

- **Platform**: x86_64-linux (physical server)
- **CPU**: AMD
- **GPU**: NVIDIA (proprietary drivers + container toolkit)
- **Network**: Static IP `10.1.30.100/24`, SSH port `2222`
- **Storage**:
  - SSD: `/ssdstorage/` (Forgejo data, fast storage)
  - HDD: `/storage/` (media, immich library, backups)

## Running Containers

All containers managed via Podman Quadlet. Modules in `hosts/common/optional/containers/`.

| Stack | Services | Domain |
|-------|----------|--------|
| traefik | Reverse proxy + wildcard LE cert | *.jennex.dev |
| pihole | DNS + ad blocking | pihole.jennex.dev |
| homepage | Dashboard | home.jennex.dev |
| pocket-id | OIDC provider | pocket.jennex.dev |
| traefik-forward-auth | SSO middleware | auth.jennex.dev |
| immich | Photo management | immich.jennex.dev |
| nextcloud | File sync | nextcloud.jennex.dev |
| forgejo | Git hosting | git.jennex.dev |
| paperless | Document management | paperless.jennex.dev |
| navidrome | Music streaming | navidrome.jennex.dev |
| audiobookshelf | Audiobook server | audiobookshelf.jennex.dev |
| calibre | Ebook library | calibre.jennex.dev |
| arr-stack | Lidarr, Radarr, Sonarr, Prowlarr, SABnzbd | *.jennex.dev |
| seerr | Overseerr media requests | seerr.jennex.dev |
| romm | ROM manager | romm.jennex.dev |
| grocy | Grocery/household | grocy.jennex.dev |
| homebox | Home inventory | homebox.jennex.dev |
| manyfold | 3D model manager | manyfold.jennex.dev |
| mealie | Recipe manager | mealie.jennex.dev |
| syncthing | File sync | syncthing.jennex.dev |
| netbox | Network documentation | netbox.jennex.dev |
| it-tools | Developer utilities | it-tools.jennex.dev |
| drawio | Diagramming | drawio.jennex.dev |
| excalidraw | Virtual whiteboard | excalidraw.jennex.dev |
| monitoring | Prometheus, Grafana, Loki, Promtail, UnPoller, podman-exporter | grafana.jennex.dev |
| netboot | PXE network boot manager | netboot.jennex.dev |
| op-connect | 1Password Connect server | localhost:8080 only |

**External services** (proxied through Traefik, not containers):
- Plex: `http://10.1.30.100:32400` → `plex.jennex.dev`

## Secrets Management

System secrets use **1Password Connect** (local self-hosted server) instead of the cloud API directly — avoids rate limits with 50+ secrets fetched on every boot.

- **Module**: `modules/nixos/op-connect-secrets.nix`
- **Secrets written to**: `/run/opnix/` (all container env-setup services reference these paths)
- **Bootstrap files** (manually placed, never managed by Nix):
  - `/etc/op-connect/1password-credentials.json` — from 1Password developer portal
  - `/etc/op-connect-token` — Connect server access token

## Rebuild Bootstrap

After a fresh NixOS install, before running `nh os switch` for the first time:

### Step 1 — NixOS install

```bash
# Boot NixOS ISO, then:
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko ./hosts/nixos/nauvoo/disko-config.nix

sudo nixos-install --flake .#nauvoo
```

### Step 2 — Bootstrap 1Password Connect credentials

**Get files from 1Password portal:**
1. Go to 1Password.com → Developer Tools → Connect Servers
2. Find (or recreate) the "nauvoo" Connect server
3. Download `1password-credentials.json`
4. Copy the Connect access token value

**Place files on the new system:**
```bash
sudo mkdir -p /etc/op-connect
sudo chmod 700 /etc/op-connect

# From your local machine:
scp -P 2222 ~/Downloads/1password-credentials.json deatrin@nauvoo:/tmp/

# On nauvoo:
sudo mv /tmp/1password-credentials.json /etc/op-connect/
sudo chmod 644 /etc/op-connect/1password-credentials.json  # must be 644 — container runs as non-root opuser

echo -n "your-connect-token-here" | sudo tee /etc/op-connect-token
sudo chmod 600 /etc/op-connect-token
```

### Step 3 — Rebuild

```bash
cd /etc/nixos && nh os switch
```

The first boot will take 30–60s while Connect performs its initial vault sync before secrets can be fetched. Subsequent boots are fast (local cache).

### Step 4 — Verify

```bash
# Secrets service
sudo systemctl status op-connect-secrets.service

# Connect containers
sudo podman ps | grep op-connect

# All containers
sudo podman ps
```

## Post-Install Notes

- **Forgejo data** lives at `/ssdstorage/forgejo` — restore from backup if rebuilding
- **Immich library** at `/storage/media/pictures/immich/library`
- **Media storage** is internal at `/storage` — verify disk is mounted with `mount | grep storage`
- **Tailscale** auto-connects on boot via op-connect secret; verify with `tailscale status`
- **Pi-hole** is the Tailscale DNS nameserver — if it's down, DNS resolution fails for all Tailscale devices

## Updating

```bash
cd /etc/nixos && git pull && nh os switch
```

## Troubleshooting

### Secrets not provisioning

```bash
sudo journalctl -u op-connect-secrets.service -n 50 --no-pager
sudo podman logs op-connect-api --tail 20
```

Common causes:
- Connect API not ready yet (syncer still initializing) — wait 60s and `sudo systemctl restart op-connect-secrets.service`
- Credentials file permissions wrong — must be `644`: `sudo chmod 644 /etc/op-connect/1password-credentials.json`
- Token file missing — `ls -la /etc/op-connect-token`

### Container not starting

```bash
# System quadlet containers don't show in plain podman ps — use sudo
sudo podman ps -a | grep <name>
sudo journalctl -u <container-name>.service -n 30 --no-pager
```

### NVIDIA GPU not detected

```bash
lspci | grep -i nvidia
nvidia-smi
```

# Nauvoo Migration Plan: Docker/Dokploy → Podman Quadlet

## Overview

Migrating nauvoo (`10.1.30.100`) from Docker/Dokploy to the new Podman Quadlet NixOS declarative
configuration. All containers have been built and tested on testbed (`10.1.40.200`) first.

---

## Phase 0 — Nix Config Changes (local machine, before touching nauvoo)

These changes need to be made to the dotfiles repo before deploying to nauvoo.

### 0.1 — Container config updates (uncomment nauvoo-specific paths)

In each file, uncomment the `/storage/media/*` volume paths and any nauvoo-specific notes:

- `hosts/common/optional/containers/navidrome/default.nix` — uncomment `/storage/media/music:/music:ro`
- `hosts/common/optional/containers/audiobookshelf/default.nix` — uncomment audiobooks/podcasts paths
- `hosts/common/optional/containers/calibre/default.nix` — uncomment `/storage/media/books`
- `hosts/common/optional/containers/arr-stack/default.nix` — uncomment all `/storage/media/*` paths
- `hosts/common/optional/containers/immich/default.nix` — uncomment `/storage/media/photos/immich` upload path
- `hosts/common/optional/containers/paperless/default.nix` — uncomment `/storage/media/documents/paperless/*` paths
- `hosts/common/optional/containers/romm/default.nix` — uncomment games library path
- `hosts/common/optional/containers/forgejo/default.nix` — swap `/var/lib/forgejo/` → `/ssdstorage/forgejo/`

### 0.2 — nauvoo/default.nix

Ensure nauvoo imports the containers module and sets nauvoo-specific options:

```nix
imports = [
  ../../common/optional/containers
  # ... existing imports
];

services.forgejo-quadlet.sshPort = 22; # system SSH is on 2222
```

### 0.3 — Homepage docker.yaml socket name

In `hosts/common/optional/containers/homepage/default.nix` (or nauvoo override),
update the socket name from `testbed-podman` → `nauvoo-podman`.

### 0.4 — nauvoo/secrets.nix

Add all required secrets (mirror testbed/secrets.nix), plus iDRAC secrets when ready:

```nix
tailscaleKey, cfApiToken, acmeEmail, traefikDashboard, piholeAdmin,
homepageUnifi{User,Pass,Latitude,Longitude}, paperlessSecret, immichEnv,
pocketId{EncryptionKey,MaxmindKey}, romm* (9 secrets), forgejo runner token (when ready)
```

---

## Phase 1 — Backup Current Data (on nauvoo)

```bash
# Stop all containers gracefully first
docker stop $(docker ps -q)

BACKUP_DIR=/storage/migration-backup/$(date +%Y%m%d)
mkdir -p $BACKUP_DIR
```

### Bind-mount paths

```bash
tar czf $BACKUP_DIR/grocy.tar.gz           -C /home/deatrin/docker_volumes grocy
tar czf $BACKUP_DIR/audiobookshelf.tar.gz  -C /home/deatrin/docker_volumes audiobookshelf
tar czf $BACKUP_DIR/homebox.tar.gz         -C /home/deatrin/docker_volumes homebox
tar czf $BACKUP_DIR/seerr.tar.gz           -C /home/deatrin/docker_volumes seerr
tar czf $BACKUP_DIR/sabnzbd.tar.gz         -C /home/deatrin/docker_volumes arr-stack
tar czf $BACKUP_DIR/pocket-id.tar.gz       -C /home/deatrin/src/homelab/pocket-id data
tar czf $BACKUP_DIR/forgejo-data.tar.gz    -C /ssdstorage/forgejo data

# Paperless + Immich are already on /storage/media — no move needed, just document
# Traefik acme.json — let LE re-issue, wildcard will auto-request on first start
```

### Docker named volumes

```bash
for vol in calibre-data etc-pihole navidrome; do
  docker run --rm -v ${vol}:/src -v $BACKUP_DIR:/dst alpine \
    tar czf /dst/${vol}-volume.tar.gz -C /src .
done

# Arr named volumes (note: docker names differ from podman names)
for svc in lidarr radarr sonarr whisparr prowlarr; do
  docker run --rm -v ${svc}:/src -v $BACKUP_DIR:/dst alpine \
    tar czf /dst/arr-${svc}-volume.tar.gz -C /src .
done
```

> **Note:** Check actual Docker volume names with `docker volume ls` — they may include
> a project prefix (e.g. `arr-stack_lidarr` instead of `lidarr`).

### Database dumps

```bash
# Romm (MariaDB)
docker exec romm-db-1 mysqldump -u romm romm > $BACKUP_DIR/romm-db.sql

# Paperless (PostgreSQL)
docker exec paperless-db-1 pg_dump -U paperless paperless > $BACKUP_DIR/paperless-db.sql

# Immich (PostgreSQL — custom pgvectors image)
docker exec immich-postgres pg_dumpall -U postgres > $BACKUP_DIR/immich-db.sql

# Forgejo (PostgreSQL)
docker exec forgejo-db-1 pg_dump -U forgejo forgejo > $BACKUP_DIR/forgejo-db.sql
```

> **Tip:** Check container names with `docker ps --format 'table {{.Names}}'` — Dokploy
> may use different names than above.

---

## Phase 2 — Deploy NixOS Quadlet Config

```bash
cd /etc/nixos && git pull
sudo nixos-rebuild switch --flake .#nauvoo
```

This creates all `systemd.tmpfiles` directories and Podman named volumes.
Containers will start empty — immediately stop them so we can restore data:

```bash
sudo systemctl stop \
  traefik pihole pocket-id \
  immich-server immich-ml immich-postgres immich-redis \
  forgejo-server forgejo-db \
  romm romm-db \
  paperless-webserver paperless-db paperless-broker \
  navidrome audiobookshelf calibre grocy homebox \
  sabnzbd recyclarr lidarr radarr sonarr whisparr prowlarr \
  seerr homepage
```

---

## Phase 3 — Restore Data

### Bind mounts

```bash
rsync -av /home/deatrin/docker_volumes/grocy/                  /var/lib/grocy/
rsync -av /home/deatrin/docker_volumes/audiobookshelf/config/  /var/lib/audiobookshelf/config/
rsync -av /home/deatrin/docker_volumes/audiobookshelf/metadata/ /var/lib/audiobookshelf/metadata/
rsync -av /home/deatrin/docker_volumes/homebox/                /var/lib/homebox/
rsync -av /home/deatrin/docker_volumes/arr-stack/              /var/lib/arr-stack/sabnzbd/
rsync -av /home/deatrin/src/homelab/pocket-id/data/            /var/lib/pocket-id/

# Forgejo — ssdstorage paths are unchanged, no move needed
# Paperless — /storage/media paths are unchanged, no move needed
# Immich upload — /storage/media paths are unchanged, no move needed
```

### Named volumes

```bash
BACKUP_DIR=/storage/migration-backup/<date>  # set to your backup date

sudo podman run --rm -v calibre-data:/dst -v $BACKUP_DIR:/src:ro \
  alpine tar xzf /src/calibre-data-volume.tar.gz -C /dst

sudo podman run --rm -v etc-pihole:/dst -v $BACKUP_DIR:/src:ro \
  alpine tar xzf /src/etc-pihole-volume.tar.gz -C /dst

sudo podman run --rm -v navidrome:/dst -v $BACKUP_DIR:/src:ro \
  alpine tar xzf /src/navidrome-volume.tar.gz -C /dst

for svc in lidarr radarr sonarr whisparr prowlarr; do
  sudo podman run --rm -v arr-${svc}:/dst -v $BACKUP_DIR:/src:ro \
    alpine tar xzf /src/arr-${svc}-volume.tar.gz -C /dst
done

sudo podman run --rm -v seerr-config:/dst -v $BACKUP_DIR:/src:ro \
  alpine tar xzf /src/seerr.tar.gz -C /dst
```

### Database restores

Start DB sidecars only, wait ~15s for them to initialize, then restore:

```bash
sudo systemctl start forgejo-db immich-postgres romm-db paperless-db paperless-broker
sleep 15

sudo podman exec -i romm-db      mysql   -u romm romm       < $BACKUP_DIR/romm-db.sql
sudo podman exec -i paperless-db psql    -U paperless paperless < $BACKUP_DIR/paperless-db.sql
sudo podman exec -i immich-postgres psql -U postgres        < $BACKUP_DIR/immich-db.sql
sudo podman exec -i forgejo-db   psql    -U forgejo forgejo  < $BACKUP_DIR/forgejo-db.sql
```

> **Note:** Podman container names may differ — check with `sudo podman ps` after starting sidecars.

---

## Phase 4 — Start Everything & Verify

```bash
sudo systemctl start \
  traefik pihole pocket-id \
  immich-server immich-ml forgejo-server romm \
  paperless-webserver navidrome audiobookshelf calibre \
  grocy homebox sabnzbd recyclarr \
  lidarr radarr sonarr whisparr prowlarr \
  seerr homepage
```

### Verification checklist

- [ ] Traefik dashboard loads, wildcard `*.deatrin.dev` cert valid (LE issued, not self-signed)
- [ ] Pi-hole DNS resolving `*.deatrin.dev` → nauvoo IP
- [ ] Homepage shows all containers with correct labels
- [ ] Forgejo: login works, repos intact, SSH on port 22
- [ ] Immich: photos library intact, machine learning working
- [ ] Paperless: documents accessible, OCR queue clear
- [ ] Romm: game library intact, scrapers working
- [ ] Arr-stack: configs/indexers/history intact in each service
- [ ] SABnzbd: config intact
- [ ] Navidrome: music library scanned and visible
- [ ] Audiobookshelf: library intact
- [ ] Calibre: library intact
- [ ] Grocy: data intact
- [ ] Homebox: inventory intact
- [ ] Pocket-ID: OIDC config intact, clients still registered
- [ ] Seerr: requests/history intact

---

## Phase 5 — Cleanup

Once everything is verified working (wait at least a few days):

```bash
# Stop Docker (don't uninstall yet — keep as fallback)
sudo systemctl stop docker
sudo systemctl disable docker

# Remove backup dir after confirming good (keep minimum 1 week)
# rm -rf /storage/migration-backup/
```

---

## Volume Path Reference

| Service | Current (Docker) | New (Podman) |
|---|---|---|
| Grocy | `/home/deatrin/docker_volumes/grocy` | `/var/lib/grocy` |
| Audiobookshelf config | `/home/deatrin/docker_volumes/audiobookshelf/config` | `/var/lib/audiobookshelf/config` |
| Audiobookshelf metadata | `/home/deatrin/docker_volumes/audiobookshelf/metadata` | `/var/lib/audiobookshelf/metadata` |
| Homebox | `/home/deatrin/docker_volumes/homebox` | `/var/lib/homebox` |
| Seerr | `/home/deatrin/docker_volumes/seerr` | named vol `seerr-config` |
| SABnzbd | `/home/deatrin/docker_volumes/arr-stack` | `/var/lib/arr-stack/sabnzbd` |
| Pocket-ID | `./data` (homelab repo) | `/var/lib/pocket-id` |
| Forgejo data | `/ssdstorage/forgejo/data` | `/ssdstorage/forgejo/data` *(unchanged)* |
| Forgejo DB | Docker named vol → pgdata | named vol `forgejo-pgdata` |
| Paperless | `/storage/media/documents/paperless/*` | same *(unchanged)* |
| Immich upload | `/storage/media/photos/immich` | same *(unchanged)* |
| Immich DB | Docker named vol | named vol `immich-pgdata` |
| Calibre | Docker named vol `data` | named vol `calibre-data` |
| Pi-hole | Docker named vol `etc-pihole` | named vol `etc-pihole` |
| Navidrome | Docker named vol `navidrome` | named vol `navidrome` |
| Lidarr | Docker named vol `lidarr` | named vol `arr-lidarr` |
| Radarr | Docker named vol `radarr` | named vol `arr-radarr` |
| Sonarr | Docker named vol `sonarr` | named vol `arr-sonarr` |
| Whisparr | Docker named vol `whisparr` | named vol `arr-whisparr` |
| Prowlarr | Docker named vol `prowlarr` | named vol `arr-prowlarr` |
| Romm DB | Docker named vol `mysql_data` | named vol `romm-mysql` |
| Romm resources | Docker named vol `romm_resources` | named vol `romm-resources` |

---

## Notes

- iDRAC fan controller (`./idrac`) — created but commented out in `default.nix`, enable when ready
- Cloudflared — punted, Tailscale subnet routing covers remote access needs
- Forgejo runner — commented out, enable after first startup + runner token setup:
  1. Log in as admin → Settings → Actions → Runners → Create registration token
  2. Add token to opnix: `op://nix_secrets/forgejo/runner_token`
  3. Add `forgejoRunnerToken` to nauvoo `secrets.nix`
  4. Uncomment dind + runner containers in `forgejo/default.nix`
- Traefik acme.json does not need to be migrated — wildcard cert will re-issue automatically on first start
- After migration update Pi-hole Tailscale nameserver from `10.1.40.200` → nauvoo IP

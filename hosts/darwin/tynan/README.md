# tynan

M1 Pro MacBook running macOS with nix-darwin and opnix secrets management.

## Hardware

- **Platform**: aarch64-darwin (Apple Silicon M1 Pro)
- **User**: deatrin
- **Repo path**: `~/src/dotfiles`

## Services & Features

| Service | Config |
|---------|--------|
| Homebrew | [hosts/darwin/tynan/homebrew.nix](homebrew.nix) |
| Home Manager | Integrated in darwin-rebuild |
| Custom Fonts | [home-manager/common/global](../../../home-manager/common/global/) |
| Ghostty | [home-manager/common/features/cli](../../../home-manager/common/features/cli/) |
| Touch ID sudo | [hosts/common/darwin/defaults.nix](../../common/darwin/defaults.nix) |
| Opnix Secrets | [hosts/darwin/tynan/secrets.nix](secrets.nix) |

### Desktop

- **Dock**: Obsidian, Spark, Brave, Messages, Raindrop.io, 1Password, Discord, VSCode, OrbStack, Termius, Ghostty, Spotify, rekordbox 7, Mixed In Key 11, Paprika Recipe Manager 3, App Store, System Settings, Yubico Authenticator, iPhone Mirroring
- **Screenshots**: `~/Pictures/Screenshots`
- **Settings**: Dark mode, fast key repeat, autohide dock

## Development Shells

6 shells available via `nix develop`:

| Shell | Command | Tools |
|-------|---------|-------|
| default | `nix develop` | nixd, nixfmt, statix, deadnix, nh |
| go | `nix develop .#go` | go, gopls, go-task, golangci-lint, delve |
| kubernetes | `nix develop .#kubernetes` | kubectl, helm, k9s, terraform, kind, talosctl |
| python | `nix develop .#python` | python3, poetry, black, ruff, mypy, pytest |
| containers | `nix develop .#containers` | docker-compose, podman, buildah, dive, hadolint |
| shell | `nix develop .#shell` | shellcheck, shfmt, bash-language-server, jq |

### Direnv integration

```bash
cd ~/projects/my-go-app
echo "use flake ~/src/dotfiles#go" > .envrc
direnv allow
```

## Secrets

System-level (opnix):
- `autin` → atuin username

User-level (opnix home-manager):
- Shell environment variables (`~/.config/shell-secrets/env`)

## Build

```bash
nh darwin switch
# or
darwin-rebuild switch --flake .#tynan
```

## Bootstrap (Fresh Machine)

### 1. Install Nix

```bash
sh <(curl -L https://nixos.org/nix/install)
```

### 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Clone repo

```bash
mkdir -p ~/src
git clone https://github.com/Deatrin/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
```

### 4. Set up opnix (REQUIRED before first build)

```bash
sudo opnix token set
# paste your 1Password service account token
```

### 5. Initial build

```bash
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#tynan
```

### 6. Post-install

```bash
# Atuin history sync
atuin login \
  --username $(op item get "atuin" --vault nix_secrets --fields label=username) \
  --password $(op item get "atuin" --vault nix_secrets --fields label=pass --reveal) \
  --key "$(op item get "atuin" --vault nix_secrets --fields label=key --reveal)"
atuin import auto
atuin sync

# Kubeconfig
mkdir -p ~/.kube
op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
```

## Troubleshooting

### Opnix token not set

```bash
sudo opnix token set
nh darwin switch
```

### Opnix secrets not provisioning

```bash
sudo launchctl list | grep opnix
sudo log show --predicate 'process == "opnix"' --last 30m
```

### Dock apps not appearing

Requires logout/login cycle after first build.

### Fonts not showing

```bash
ls ~/Library/Fonts/
```

May require restarting apps or logging out.

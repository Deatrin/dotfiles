# donnager

iMac Pro running macOS with nix-darwin.

## Hardware

- **Platform**: x86_64-darwin (Intel)
- **Model**: iMac Pro
- **User**: ajennex
- **Repo path**: `~/src/dotfiles`

## Services & Features

| Service | Config |
|---------|--------|
| Homebrew | [hosts/darwin/donnager/homebrew.nix](homebrew.nix) |
| Home Manager | Integrated in darwin-rebuild |
| Custom Fonts | [home-manager/common/global](../../../home-manager/common/global/) |
| Ghostty | [home-manager/common/features/cli](../../../home-manager/common/features/cli/) |
| Touch ID sudo | [hosts/common/darwin/defaults.nix](../../common/darwin/defaults.nix) |

### Desktop

- **Dock**: TickTick, Notion, Canary Mail, Brave, Messages, Raindrop.io, 1Password, Discord, VSCode, OrbStack, Termius, Ghostty, Spotify, rekordbox 7, Mixed In Key 11, App Store, System Settings, Yubico Authenticator, iPhone Mirroring
- **Screenshots**: `~/Pictures/Screenshots`
- **Settings**: Dark mode, fast key repeat, autohide dock

## Build

```bash
nh darwin switch
# or
darwin-rebuild switch --flake .#donnager
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

### 4. Initial build

```bash
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#donnager
```

### 5. Post-install

```bash
# Atuin history sync
atuin login \
  --username $(op item get "atuin - THD" --vault Work --fields label=username) \
  --password $(op item get "atuin - THD" --vault Work --fields label=password) \
  --key "$(op item get "atuin - THD" --vault Work --fields label=key)"
atuin import auto
atuin sync
```

## Troubleshooting

### Dock apps not appearing

Requires logout/login cycle after first build.

### Homebrew apps not installing

```bash
brew bundle --file=~/src/dotfiles/hosts/darwin/donnager/Brewfile
```

### Touch ID sudo not working

```bash
cat /etc/pam.d/sudo | grep pam_tid.so
# if missing, rebuild
nh darwin switch
```

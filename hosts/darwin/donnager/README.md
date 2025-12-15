# donnager

iMac Pro running macOS with nix-darwin.

## Hardware Specifications

- **Platform**: x86_64-darwin (Intel Mac)
- **Model**: iMac Pro
- **User**: ajennex

## Enabled Services & Features

### System Services

| Service | Description | Config Location |
|---------|-------------|-----------------|
| Homebrew | Package management for GUI apps | [hosts/darwin/donnager/homebrew.nix](homebrew.nix) |
| Nix Flakes | Declarative system configuration | [hosts/common/darwin/defaults.nix](../../common/darwin/defaults.nix) |
| Home Manager | User environment management | Integrated in darwin-rebuild |
| Custom Fonts | Monaspace, JetBrains Mono Nerd Font | [home-manager/common/global](../../../home-manager/common/global/) |
| Ghostty | Modern terminal emulator | [home-manager/common/features/cli](../../../home-manager/common/features/cli/) |
| Touch ID sudo | Biometric authentication for sudo | [hosts/common/darwin/defaults.nix](../../common/darwin/defaults.nix) |
| YubiKey Support | Hardware authentication | Via home-manager |

### Desktop Configuration

- **Dock Apps**: TickTick, Notion, Canary Mail, Brave Browser, Messages, Raindrop.io, 1Password, Discord, VSCode, OrbStack, Termius, Ghostty, Spotify, rekordbox 7, Mixed In Key 11, App Store, System Settings, Yubico Authenticator, iPhone Mirroring
- **Screenshot Location**: /Users/ajennex/Pictures/Screenshots
- **System Settings**: Dark mode, fast key repeat, autohide dock

### Development Tools

- Kubernetes tools via home-manager: k9s, kubectl
- terminal-notifier for macOS notifications
- Development features available via home-manager

### Secrets Management

No system-level opnix secrets configured currently.

User-level secrets can be configured via opnix in home-manager if needed.

## From Fresh Machine to Fully Configured

### Prerequisites

1. **macOS** installed and updated
2. **iCloud/App Store login** (required for MAS to work)
3. **1Password account** with service account token (if using secrets)

### Installation Steps

#### Step 1: Install Nix

Install the Nix package manager:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Follow the prompts to complete installation. After installation, restart your terminal.

#### Step 2: Install Homebrew

Install Homebrew for GUI applications:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Note**: Homebrew is used for GUI apps that don't work well with Nix (Spotlight indexing issues).

#### Step 3: Clone Repository

```bash
mkdir -p ~/.config
git clone https://github.com/Deatrin/dotfiles-redux.git ~/.config/dotfiles
cd ~/.config/dotfiles
```

#### Step 4: Initial Build

Run the initial build with nix-darwin:

```bash
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#donnager
```

This will:
- Install nix-darwin
- Apply system configuration
- Install home-manager and user configuration
- Install Homebrew packages

#### Step 5: Subsequent Rebuilds

After the initial build, use the standard rebuild command:

```bash
darwin-rebuild switch --flake .#donnager
# or with nh (recommended)
nh home switch
```

**Note**: Home-manager is integrated - no need to run it separately!

#### Step 6: Post-Installation Setup

1. **Authenticate with 1Password** (if using secrets):
   ```bash
   eval $(op signin --account <your-account>.1password.com)
   ```

2. **Setup atuin** (shell history sync):
   ```bash
   atuin login --username $(op item get "atuin - THD" --vault Work --fields label=username) \
               --password $(op item get "atuin - THD" --vault Work --fields label=password) \
               --key "$(op item get "atuin - THD" --vault Work --fields label=key)"
   atuin import auto
   atuin sync
   ```

3. **Setup kubeconfig** (if needed):
   ```bash
   mkdir -p ~/.kube
   op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
   ```

4. **Setup YubiKey for SSH** (optional):
   ```bash
   # YubiKey support is configured via home-manager
   # Insert YubiKey and test SSH agent
   ssh-add -L
   ```

5. **Restart terminal** to load all new configurations

#### Step 7: Verify Installation

Check that everything is working:

```bash
# Check Nix version
nix --version

# Check nix-darwin
darwin-rebuild --version

# Check Homebrew packages
brew list

# Check shell
echo $SHELL  # Should be zsh

# Check Ghostty terminal is installed
which ghostty
```

### Troubleshooting

#### Homebrew Apps Not Installing

If Homebrew apps fail to install during rebuild:

```bash
brew bundle --file=~/.config/dotfiles/hosts/darwin/donnager/Brewfile
```

#### Touch ID sudo Not Working

Verify Touch ID is configured for sudo:

```bash
cat /etc/pam.d/sudo | grep pam_tid.so
```

If not present, rebuild:

```bash
darwin-rebuild switch --flake .#donnager
```

#### Dock Apps Not Appearing

The dock configuration requires a logout/login cycle. Log out and back in to see the configured dock apps.

#### Home-manager Not Activating

Home-manager is integrated into darwin-rebuild. Don't run `home-manager switch` separately. If issues persist:

```bash
# Rebuild with verbose output
darwin-rebuild switch --flake .#donnager --show-trace
```

#### Fonts Not Showing Up

Fonts may require restarting applications or logging out. Check font installation:

```bash
ls ~/Library/Fonts/
```

## Updating Configuration

To update the configuration from GitHub and rebuild:

```bash
cd ~/.config/dotfiles
git pull
darwin-rebuild switch --flake .#donnager
# or with nh
nh home switch
```

## Update Flake Inputs

To update all Nix packages:

```bash
cd ~/.config/dotfiles
nix flake update
darwin-rebuild switch --flake .#donnager
```

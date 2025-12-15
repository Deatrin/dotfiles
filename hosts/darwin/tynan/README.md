# tynan

M1 Pro MacBook running macOS with nix-darwin and opnix secrets management.

## Hardware Specifications

- **Platform**: aarch64-darwin (Apple Silicon)
- **Model**: MacBook Pro (M1 Pro)
- **User**: deatrin

## Enabled Services & Features

### System Services

| Service | Description | Config Location |
|---------|-------------|-----------------|
| Homebrew | Package management for GUI apps | [hosts/darwin/tynan/homebrew.nix](homebrew.nix) |
| Nix Flakes | Declarative system configuration | [hosts/common/darwin/defaults.nix](../../common/darwin/defaults.nix) |
| Home Manager | User environment management | Integrated in darwin-rebuild |
| Custom Fonts | Monaspace, JetBrains Mono Nerd Font | [home-manager/common/global](../../../home-manager/common/global/) |
| Ghostty | Modern terminal emulator | [home-manager/common/features/cli](../../../home-manager/common/features/cli/) |
| Touch ID sudo | Biometric authentication for sudo | [hosts/common/darwin/defaults.nix](../../common/darwin/defaults.nix) |
| YubiKey Support | Hardware authentication | Via home-manager |
| **Opnix Secrets** | **1Password integration** | **[hosts/darwin/tynan/secrets.nix](secrets.nix)** |

### Desktop Configuration

- **Dock Apps**: Obsidian, Spark, Brave Browser, Messages, Raindrop.io, 1Password, Discord, VSCode, OrbStack, Termius, Ghostty, Spotify, rekordbox 7, Mixed In Key 11, Paprika Recipe Manager 3, App Store, System Settings, Yubico Authenticator, iPhone Mirroring
- **Screenshot Location**: /Users/deatrin/Pictures/Screenshots
- **System Settings**: Dark mode, fast key repeat, autohide dock

### Development Tools

- Kubernetes tools via home-manager: k9s, kubectl
- terminal-notifier for macOS notifications
- Development features available via home-manager

## Development Shells

This repository provides **6 specialized development shells** that can be activated on-demand with `nix develop`. Each shell provides a complete, isolated development environment with all necessary tools pre-configured.

### Available Shells

| Shell | Command | Description |
|-------|---------|-------------|
| **default** | `nix develop` | Dotfiles development (Nix tools, formatters, linters) |
| **go** | `nix develop .#go` | Go development environment with gopls, go-task, golangci-lint |
| **kubernetes** | `nix develop .#kubernetes` | Complete K8s toolkit (kubectl, helm, k9s, terraform, etc.) |
| **python** | `nix develop .#python` | Python 3.13 with poetry, black, ruff, mypy, pytest |
| **containers** | `nix develop .#containers` | Container tools (docker-compose, podman, buildah, hadolint) |
| **shell** | `nix develop .#shell` | Shell scripting (shellcheck, shfmt, bash-language-server) |

### Usage Examples

#### Quick Shell Access

Enter a development shell directly:

```bash
# Default dotfiles development shell
nix develop

# Go development
nix develop .#go

# Kubernetes work
nix develop .#kubernetes
```

Each shell displays a welcome message with available tools and sets up environment variables automatically.

#### Project-Specific Shells with Direnv

For automatic shell activation when entering a project directory, use **direnv** (already configured on tynan):

```bash
# In your project directory
cd ~/projects/my-go-app

# Create .envrc to auto-load Go shell
echo "use flake ~/.config/dotfiles#go" > .envrc
direnv allow

# Now the Go shell activates automatically when you cd into this directory!
# GOPATH is set, gopls is available, etc.
```

**Examples for different project types:**

```bash
# Python project
echo "use flake ~/.config/dotfiles#python" > .envrc

# Kubernetes/Infrastructure project
echo "use flake ~/.config/dotfiles#kubernetes" > .envrc

# Container development
echo "use flake ~/.config/dotfiles#containers" > .envrc

# Shell script project
echo "use flake ~/.config/dotfiles#shell" > .envrc
```

#### Using Shells from Any Directory

Reference the full flake path to use shells from anywhere:

```bash
# From any directory
nix develop /Users/deatrin/.config/dotfiles#go

# Or with relative path
nix develop ~/src/dotfiles-redux#kubernetes
```

### What Each Shell Provides

**default (Dotfiles Development)**
- Nix tools: `nixd`, `nixfmt-rfc-style`, `nix-tree`, `nvd`, `statix`, `deadnix`, `manix`
- Build tools: `nixos-rebuild`, `home-manager`, `nh`
- Perfect for: Maintaining this dotfiles repository

**go**
- Go toolchain (v1.25.4+)
- LSP: `gopls`
- Tools: `go-task`, `golangci-lint`, `delve`, `gomodifytags`, `gotests`, `golines`, `gofumpt`
- Auto-configures: `GOPATH=$HOME/go`
- Perfect for: Go application development

**kubernetes**
- Core: `kubectl`, `kubernetes-helm`, `kustomize`, `fluxcd`, `talosctl`, `k9s`
- Development clusters: `kind`, `minikube`
- Utilities: `krew`, `kubectx`, `kubens`, `stern`, `kail`
- IaC: `opentofu`, `terragrunt`, `tflint`, `terraform-docs`
- Custom: `kubectl-browse-pvc` (local package)
- Auto-configures: `KUBECONFIG=$HOME/.kube/config`
- Perfect for: Kubernetes cluster management, infrastructure as code

**python**
- Python 3.13.9
- Package management: `poetry`, `pipenv`
- Formatting: `black`
- Linting: `ruff`, `mypy`
- Testing: `pytest`
- Interactive: `ipython`
- Auto-configures: `PYTHONPATH` includes current directory
- Perfect for: Python application development

**containers**
- Container tools: `docker-compose`, `docker-buildx`, `buildah`, `podman`
- Image analysis: `dive`, `hadolint`
- Utilities: `skopeo`, `compose2nix`, `ctop`, `lazydocker`
- Perfect for: Docker/container development and debugging

**shell**
- Linting: `shellcheck`
- Formatting: `shfmt`
- LSP: `bash-language-server`
- Data tools: `jq`, `yq`, `sd`, `ripgrep`, `fd`
- Testing: `bats`
- Perfect for: Shell script development

### Tips

1. **Check available shells**: `nix flake show ~/.config/dotfiles` shows all available shells
2. **Shell without building**: Shells are lazy-evaluated - only downloaded when first used
3. **Multiple projects**: Each project can use a different shell via direnv
4. **Reproducible environments**: Everyone using your project gets identical tool versions
5. **No global installation**: Tools are isolated per-shell, no conflicts with system packages

### Secrets Management

**System-level opnix secrets** (configured in secrets.nix):
- **autin**: Atuin username from op://nix_secrets/atuin/username

**User-level secrets** via opnix (configured in home-manager):
- Shell environment variables (1Password personal vault)

## From Fresh Machine to Fully Configured

### Prerequisites

1. **macOS** installed and updated
2. **iCloud/App Store login** (required for MAS to work)
3. **1Password account** with service account token (**REQUIRED for tynan**)

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

#### Step 4: Setup Opnix (CRITICAL FOR TYNAN)

**Before building**, set up opnix for 1Password secrets management:

```bash
# Set opnix service account token
sudo opnix token set
# Paste your 1Password service account token when prompted
```

**Important**: This must be done BEFORE the first build, as the system configuration depends on opnix secrets being available.

#### Step 5: Initial Build

Run the initial build with nix-darwin:

```bash
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#tynan
```

This will:
- Install nix-darwin
- Apply system configuration
- Provision opnix secrets (system and user level)
- Install home-manager and user configuration
- Install Homebrew packages

#### Step 6: Subsequent Rebuilds

After the initial build, use the standard rebuild command:

```bash
darwin-rebuild switch --flake .#tynan
# or with nh (recommended)
nh home switch
```

**Note**: Home-manager is integrated - no need to run it separately!

#### Step 7: Post-Installation Setup

1. **Verify opnix secrets are provisioned**:
   ```bash
   # Check system secrets
   sudo ls -la /usr/local/var/opnix/secrets/

   # Check user secrets
   ls -la ~/.config/shell-secrets/
   ```

2. **Authenticate with 1Password** (for manual secret access):
   ```bash
   eval $(op signin --account <your-account>.1password.com)
   ```

3. **Setup atuin** (shell history sync):
   ```bash
   atuin login --username $(op item get "atuin" --vault nix_secrets --fields label=username) \
               --password $(op item get "atuin" --vault nix_secrets --fields label=pass --reveal) \
               --key "$(op item get "atuin" --vault nix_secrets --fields label=key --reveal)"
   atuin import auto
   atuin sync
   ```

4. **Setup kubeconfig** (if needed):
   ```bash
   mkdir -p ~/.kube
   op document get --vault kubernetes 'k3s.yaml' --out-file ~/.kube/config
   ```

5. **Setup YubiKey for SSH** (optional):
   ```bash
   # YubiKey support is configured via home-manager
   # Insert YubiKey and test SSH agent
   ssh-add -L
   ```

6. **Restart terminal** to load all new configurations

#### Step 8: Verify Installation

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

# Verify opnix secrets are accessible
sudo cat /usr/local/var/opnix/secrets/autin  # Should show atuin username
```

### Troubleshooting

#### Opnix Token Not Set

If the build fails with opnix errors:

```bash
# Set the token
sudo opnix token set

# Rebuild
darwin-rebuild switch --flake .#tynan
```

#### Opnix Secrets Not Provisioning

Check opnix service status:

```bash
# Check if opnix is running
sudo launchctl list | grep opnix

# View opnix logs
sudo log show --predicate 'process == "opnix"' --last 30m
```

If secrets aren't provisioning, rebuild:

```bash
darwin-rebuild switch --flake .#tynan
```

#### Homebrew Apps Not Installing

If Homebrew apps fail to install during rebuild:

```bash
brew bundle --file=~/.config/dotfiles/hosts/darwin/tynan/Brewfile
```

#### Touch ID sudo Not Working

Verify Touch ID is configured for sudo:

```bash
cat /etc/pam.d/sudo | grep pam_tid.so
```

If not present, rebuild:

```bash
darwin-rebuild switch --flake .#tynan
```

#### Dock Apps Not Appearing

The dock configuration requires a logout/login cycle. Log out and back in to see the configured dock apps.

#### Home-manager Not Activating

Home-manager is integrated into darwin-rebuild. Don't run `home-manager switch` separately. If issues persist:

```bash
# Rebuild with verbose output
darwin-rebuild switch --flake .#tynan --show-trace
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
darwin-rebuild switch --flake .#tynan
# or with nh
nh home switch
```

## Update Flake Inputs

To update all Nix packages:

```bash
cd ~/.config/dotfiles
nix flake update
darwin-rebuild switch --flake .#tynan
```

## Opnix Secret Management

For more information about opnix configuration and secret management, see [CLAUDE.md](../../../CLAUDE.md#secrets-management-opnix).

**Key points**:
- Secret names must be camelCase (e.g., `autin` not `au-tin`)
- System secrets are configured in `hosts/darwin/tynan/secrets.nix`
- User secrets are configured in home-manager opnix modules
- Service account token is stored in `/etc/opnix-token`

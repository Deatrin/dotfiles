# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS/nix-darwin dotfiles repository that manages system configurations across multiple machines using Nix flakes. The configuration supports both macOS (via nix-darwin) and NixOS systems, with user-level configuration managed through home-manager.

## User Preferences

**IMPORTANT:** Do NOT run rebuild commands (`darwin-rebuild switch`, `nixos-rebuild switch`, `nh os switch`, etc.) automatically. The user prefers to run these commands manually to test and verify changes themselves.

## Build and Deployment Commands

### NixOS Systems
```bash
# Build and activate NixOS configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Available NixOS hosts: nauvoo, razerback, tycho
# Example:
sudo nixos-rebuild switch --flake .#nauvoo
```

### macOS Systems (nix-darwin)
```bash
# Build and activate darwin configuration (includes home-manager)
darwin-rebuild switch --flake .#<hostname>

# Available darwin hosts: barkeith, chetzemoka, donnager, tynan
# Example:
darwin-rebuild switch --flake .#barkeith

# Note: home-manager is integrated - no need to run separately!
```

### Home Manager (Standalone - Not Needed!)
```bash
# Home-manager is now integrated into both NixOS and Darwin builds
# No need to run home-manager separately!

# For NixOS: use nixos-rebuild switch
# For Darwin: use darwin-rebuild switch

# Standalone home-manager configurations still exist in the flake
# but are not used during normal system rebuilds
```

### Using nh (recommended)
```bash
# For NixOS systems
nh os switch

# For Darwin systems
nh darwin switch

# For home-manager only
nh home switch
```

**nh Configuration:**
- Configured via home-manager (`home-manager/common/features/cli/nh.nix`)
- NH_FLAKE environment variable set per-user:
  - NixOS: `/etc/nixos`
  - Darwin: `/Users/<username>/src/dotfiles`
- Automatic weekly garbage collection enabled (keeps last 5 generations + 7 days)
- Note: System package also installed for root access redundancy

### Flake Management
```bash
# Update flake inputs
nix flake update

# Update specific input
nix flake lock --update-input <input-name>

# Check flake
nix flake check
```

### Development Shells

The repository provides 6 development shells for different workflows:

```bash
# Default: Dotfiles development (nixd, nixfmt, statix, etc.)
nix develop

# Named shells
nix develop .#go            # Go development
nix develop .#kubernetes    # K8s & infrastructure tools
nix develop .#python        # Python development
nix develop .#containers    # Container/Docker development
nix develop .#shell         # Shell scripting
```

**Direnv Integration:**

Create `.envrc` in your project directory:
```bash
use flake /path/to/dotfiles#go
direnv allow
```

**Available Tools by Shell:**
- **default**: nixd, nixfmt-rfc-style, nix-tree, nvd, statix, deadnix, manix, nh, home-manager, nixos-rebuild (darwin-rebuild available via nix-darwin on macOS)
- **go**: go, gopls, gotools, go-task, golangci-lint, delve, gomodifytags, gotests, golines, gofumpt
- **kubernetes**: kubectl, helm, kustomize, fluxcd, talosctl, k9s, kind, minikube, krew, kubectx (includes kubens), stern, kail, opentofu, terragrunt, tflint, terraform-docs, kubectl-browse-pvc
- **python**: python3, poetry, pipenv, black, ruff, mypy, pytest, ipython
- **containers**: docker-compose, docker-buildx, hadolint, dive, skopeo, buildah, podman, compose2nix, ctop, lazydocker
- **shell**: shellcheck, shfmt, bash-language-server, jq, yq, sd, ripgrep, fd, bats

### Secrets Management (opnix)

**Migration Status:** Fully migrated from agenix to opnix. Legacy agenix .age files preserved in `secrets/` directory for reference.

### 1Password Integration (opnix)

Opnix provides 1Password secrets management across all systems. The opnix modules are **self-contained** and automatically provide the `opnix` CLI tool.

**Configuration:**
- **NixOS**: `inputs.opnix.nixosModules.default` imported in `hosts/common/nixos/default.nix`
  - System secrets configured per-host in `hosts/nixos/<hostname>/secrets.nix`
  - Secrets stored in `/run/opnix/` (systemd managed)
  - Uses systemd for lifecycle management
  - Example: `hosts/nixos/tycho/secrets.nix`

- **Darwin**: `inputs.opnix.darwinModules.default` imported in `hosts/common/darwin/defaults.nix`
  - System secrets configured per-host in `hosts/darwin/<hostname>/secrets.nix`
  - Secrets stored in `/usr/local/var/opnix/secrets/`
  - Uses launchd for lifecycle management
  - Example: `hosts/darwin/tynan/secrets.nix`

- **Home-Manager**: `inputs.opnix.homeManagerModules.default` imported in `home-manager/common/global/default.nix`
  - User secrets split into `opnix_personal.nix` and `opnix_servers.nix` for organization
  - Import in per-user configs (e.g., `home-manager/darwin/tynan.nix`, `home-manager/nixos/deatrin_tycho.nix`)
  - Secrets stored relative to home directory
  - Same configuration works on both NixOS and Darwin

**Initial Setup (Per Host):**

1. Create a 1Password Service Account (in Developer Settings)
   - Grant read access to relevant vaults

2. Authenticate with 1Password CLI:
   ```bash
   eval $(op signin --account <account>.1password.com)
   ```

3. Set opnix service account token:
   ```bash
   sudo opnix token set
   ```

4. Rebuild system (secrets provisioned automatically):
   ```bash
   darwin-rebuild switch --flake .#<host>          # Darwin
   sudo nixos-rebuild switch --flake .#<host>      # NixOS
   ```

**Adding System Secrets:**

In host-specific `secrets.nix` (e.g., `hosts/nixos/tycho/secrets.nix` or `hosts/darwin/tynan/secrets.nix`):

**IMPORTANT:** Secret names must be camelCase (e.g., `tailscaleKey`, `databasePassword`), NOT kebab-case or snake_case.

```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";              # Service account token file
    users = ["username"];                         # Add users to onepassword-secrets group
    secrets = {
      # Secret names MUST be camelCase!
      tailscaleKey = {                           # ✅ Good: camelCase
        path = "/run/opnix/tailscale-key";       # Absolute path required (NixOS)
        reference = "op://vault/item/field";     # Format: op://<vault>/<item>/<field>
        owner = "root";
        group = "root";
        mode = "0600";
      };
      databasePassword = {                       # ✅ Good: camelCase
        path = "/etc/myservice/db-password";
        reference = "op://vault/database/password";
        owner = "myservice";
        group = "myservice";
        mode = "0400";
      };
    };
    restartServices = [ "myservice" ];           # Optional: Auto-restart on secret change
  };
}
```

**Note:** On Darwin, use absolute paths like `/usr/local/var/myservice/secret`.

**Adding User Secrets (Optional):**

User-level secrets are split into two files for organization:
- `home-manager/common/features/cli/opnix_personal.nix` - Personal vault secrets
- `home-manager/common/features/cli/opnix_servers.nix` - Server vault secrets

Import the appropriate file in your user's home-manager config (e.g., `home-manager/darwin/tynan.nix`):
```nix
{
  imports = [
    ../common/features/cli/opnix_personal.nix
  ];
}
```

Then configure secrets in the respective file:

**IMPORTANT:** Secret names must be camelCase (same rule as system secrets).

```nix
{
  programs.onepassword-secrets = {
    enable = true;
    secrets = {
      # Secret names MUST be camelCase!
      shellSecrets = {                           # ✅ Good: camelCase
        path = ".config/shell-secrets/env";      # Relative to home directory
        reference = "op://vault/item/field";
        mode = "0600";
      };
      sshPrivateKey = {                          # ✅ Good: camelCase
        path = ".ssh/id_rsa";
        reference = "op://Personal/ssh-key/private-key";
        mode = "0600";
      };
    };
  };
}
```

## Architecture

### Flake-Parts Structure

This repository uses **flake-parts** for modular flake organization. The flake is a clean 60-line orchestrator with separate modules.

**Key Benefits:**
- Data-driven factories eliminate boilerplate
- Easy host management - add new hosts by editing a single data file
- perSystem integration for automatic multi-system package/overlay support

### Repository Structure

The repository uses a modular architecture with configuration split across multiple directories:

- **flake.nix**: Minimal orchestrator (60 lines) that imports flake-parts modules
- **flake/**: Flake-parts modules directory
  - **flake/hosts.nix**: Single source of truth for all host metadata (systems, users, module paths)
  - **flake/lib.nix**: Helper functions (mkNixos, mkDarwin, mkHome) with automatic specialArgs
  - **flake/packages.nix**: perSystem packages module
  - **flake/overlays.nix**: perSystem overlays module with pkgs and pkgs-unstable setup
  - **flake/nixos.nix**: NixOS configuration factory (auto-generates from hosts.nix)
  - **flake/darwin.nix**: Darwin configuration factory (auto-generates from hosts.nix)
  - **flake/home-manager.nix**: Home-manager configuration factory (auto-generates from hosts.nix)
- **hosts/**: Per-machine system-level configuration (NixOS and nix-darwin)
  - **hosts/common/darwin/**: Shared macOS configuration (defaults, homebrew)
  - **hosts/common/nixos/**: Shared NixOS configuration (locale, nix, openssh, tailscale)
  - **hosts/common/optional/**: Optional modules (docker, podman, fonts, plex, jellyseerr)
  - **hosts/common/containers/**: Docker compose configurations
  - Each host directory contains: default.nix, hardware-configuration.nix (for NixOS), disko-config.nix (for disk partitioning)
- **home-manager/**: Per-user configuration across machines
  - **home-manager/common/global/**: Global user configuration imported by all users
  - **home-manager/common/features/cli/**: CLI tool configurations (git, zsh, tmux, nvf, etc.)
  - **home-manager/common/features/desktop/**: Desktop environment configs (hyprland, rofi, theming)
  - **home-manager/common/features/dev/**: Development environment configurations
  - **home-manager/common/features/kubernetes/**: Kubernetes tooling (k9s, kubectl)
- **modules/**: Custom NixOS and home-manager modules
- **overlays/**: Custom package overlays including unstable packages
- **pkgs/**: Custom packages not available in nixpkgs
- **secrets/**: Legacy agenix .age files (preserved for reference; opnix now used for secrets management)
- **keys/**: Public GPG keys
- **hosts/VMtemplate/**: Template configuration for quick VM setup

### Configuration Flow

1. **System Level**: Each host imports from hosts/common/{darwin,nixos}/ for OS-level configuration
2. **User Level**: home-manager configurations import from home-manager/common/global/ which includes CLI features by default
3. **Features**: Features are opt-in modules that can be imported per-machine (e.g., desktop, kubernetes, dev tools)
4. **Secrets**: Encrypted secrets in secrets/ are referenced in host-specific secrets.nix files

### Key Design Patterns

- **Separation of Concerns**: System configuration (hosts/) is separate from user configuration (home-manager/)
- **Common + Specific**: Common configurations are shared, host-specific configs override or extend
- **Feature Modules**: Features are modular and imported only where needed
- **Dual OS Support**: The same flake manages both NixOS and macOS systems using appropriate modules
- **Unified Home Manager**: User configurations work across both NixOS and macOS with platform-specific imports (e.g., ghostty.nix vs ghostty_mac.nix)
- **Data-Driven Factories**: All configurations generated from flake/hosts.nix data structure using factory modules

### Adding New Hosts

With the flake-parts architecture, adding a new host is straightforward. Simply edit `flake/hosts.nix`:

**For a new NixOS host:**
```nix
# In flake/hosts.nix, add to nixosHosts:
myNewServer = {
  system = "x86_64-linux";
  user = "username";
  modules = [../hosts/nixos/myNewServer];
};
```

**For a new Darwin host:**
```nix
# In flake/hosts.nix, add to darwinHosts:
myNewMac = {
  system = "aarch64-darwin";  # or x86_64-darwin for Intel
  user = "username";
  modules = [../hosts/darwin/myNewMac];
};
```

**For a new home-manager config:**
```nix
# In flake/hosts.nix, add to homeConfigs:
"username@hostname" = {
  system = "x86_64-linux";  # or appropriate darwin system
  modules = [../home-manager/username_hostname.nix];
};
```

Then create the corresponding host directory in `hosts/nixos/` (for NixOS hosts) or `hosts/darwin/` (for Darwin hosts), or home-manager file as usual. The factory modules will automatically generate the configuration.

## Host Information

### NixOS Hosts
- **nauvoo**: VM with NVIDIA GPU, Docker, Plex, Jellyseerr (SSH port 2222)
- **razerback**: Dell Precision 5760 laptop
- **tycho**: Lenovo T14 G3 laptop with Hyprland desktop (greetd/tuigreet login, hyprlock screen lock)
- **VMtemplate**: Template configuration for quick VM deployment (not a production host)

### macOS Hosts
- **barkeith**: Intel MacBook Pro (x86_64-darwin), user: ajennex
- **chetzemoka**: M2 MacBook Air (aarch64-darwin), user: ajennex
- **donnager**: iMac Pro (x86_64-darwin), user: ajennex
- **tynan**: M1 Pro MacBook (aarch64-darwin), user: deatrin

## Recent Developments

### Tokyo Night Theme Migration
- **Migrated entire dotfiles** from Dracula to Tokyo Night Dark theme
- **Custom colorscheme module**: Created `modules/home-manager/colorschemes/tokyo-night.nix` with base16 Tokyo Night Dark palette
- **Global change**: Updated `home-manager/common/global/default.nix` to use custom colorscheme instead of nix-colors Dracula
- **CLI tools updated** (all platforms):
  - Neovim: Tokyo Night theme with "night" style variant
  - FZF: Complete Tokyo Night color palette
  - Bat: Tokyo Night syntax highlighting (fetched from folke/tokyonight.nvim)
  - Ghostty: Consolidated configuration already using Tokyo Night
- **Desktop updated** (NixOS only):
  - GTK: Tokyonight-Dark theme
  - Icons: Papirus-Dark (neutral theme)
  - Hyprland: GTK_THEME environment variable
  - Rofi: Custom tokyo-night.rasi theme file
- **Files changed**: 9 total (1 new, 7 modified, 1 deleted)
  - Created: `modules/home-manager/colorschemes/tokyo-night.nix`
  - Modified: global/default.nix, nvf.nix, fzf.nix, bat.nix, theme.nix, hyprland.nix, rofi.nix
  - Deleted: `ghostty_mac.nix` (consolidated into ghostty.nix)
- **Validated**: Darwin builds working, NixOS desktop pending user rebuild

### nh Migration to Home-Manager
- **Migrated nh configuration** from system-level to home-manager for consistency across platforms
- **New module**: `home-manager/common/features/cli/nh.nix` with platform-aware and user-aware flake path configuration
- **Per-user NH_FLAKE**: Automatically set based on platform and username
  - NixOS: `/etc/nixos` for all users
  - Darwin: `/Users/<username>/src/dotfiles` per user
- **Garbage collection**: Automatic weekly cleanup enabled (keeps 5 generations + 7 days)
- **Removed**: System-level `NH_FLAKE` from `hosts/common/nixos/default.nix` to avoid conflicts
- **Maintained**: System-level package installation for root access redundancy
- **Impact**: Darwin users now have NH_FLAKE set automatically (previously required manual `--flake` argument)
- **Files modified**:
  - Created: `home-manager/common/features/cli/nh.nix`
  - Modified: `home-manager/common/features/cli/default.nix`
  - Modified: `hosts/common/nixos/default.nix` (removed NH_FLAKE)

### Tailscale Autoconnect Fix
- **Fixed service ordering issue** preventing Tailscale autoconnect on nauvoo
- **Root cause**: `tailscale-autoconnect.service` was starting before `opnix-secrets.service` had provisioned the secret file
- **Solution**: Added proper systemd dependencies in `hosts/common/nixos/tailscale.nix`
  - Added `opnix-secrets.service` to `after` and `requires` lists
  - Added `RemainAfterExit = true` to keep oneshot service marked as active
  - Increased timeout to 60s and added better error handling/logging
  - Changed to native Tailscale file auth: `--authkey "file:/run/opnix/tailscale-key"`
- **Impact**: Tailscale now reliably auto-connects on boot for all NixOS hosts
- **Files modified**: `hosts/common/nixos/tailscale.nix`

### Custom SSH Port on Nauvoo
- **Changed SSH port to 2222** on nauvoo to make room for Forgejo
- **Configuration**: Set `services.openssh.ports = [2222]` with explicit `openFirewall = true`
- **Host-specific**: Only nauvoo uses custom SSH port; all other hosts remain on default port 22
- **Important**: When connecting to nauvoo, must use `ssh -p 2222 user@nauvoo` or configure in `~/.ssh/config`
- **Files modified**: `hosts/nixos/nauvoo/default.nix`

### DevShells Implementation
- **Implemented 6 development shells** using flake-parts perSystem pattern
  - `default`: Dotfiles development (Nix tools, formatters, linters)
  - `go`: Go 1.25.4 with full toolchain (gopls, go-task, golangci-lint, delve)
  - `kubernetes`: Complete K8s toolkit (kubectl, helm, k9s, terraform, kind, minikube)
  - `python`: Python 3.13.9 with poetry, black, ruff, mypy, pytest
  - `containers`: Docker/container tools (docker-compose, podman, buildah, hadolint, dive)
  - `shell`: Shell scripting (shellcheck, shfmt, bash-language-server)
- **Files**: New `flake/devshells.nix` module following perSystem pattern from packages.nix
- **Documentation**: Added comprehensive devShells section to tynan README with direnv examples
- **Usage**: `nix develop .#<shell-name>` or auto-activate with direnv per-project
- **Validated**: All shells tested and working, cross-platform (NixOS + Darwin)

### Network Topology (nix-topology)
- **Integrated nix-topology** for automated infrastructure diagram generation from NixOS/Darwin configurations
- **Hosts included**: 3 NixOS hosts (nauvoo, razerback, tycho - auto-extracted) + tynan (Darwin - manual)
- **External devices**: Router, switches, NAS documented in topology-config.nix
- **Dual views**: Physical connections (main.svg) + network-centric (network.svg) diagrams
- **Files**:
  - `flake/topology.nix`: Flake-parts perSystem module integration
  - `topology-config.nix`: Global topology configuration with networks, nodes, and physical connections
  - `hosts/common/nixos/default.nix`: NixOS module enabled for all Linux hosts
- **Build commands**:
  ```bash
  # For x86_64-linux hosts (requires Linux builder or run on Linux host)
  nix build .#topology.x86_64-linux.config.output

  # For aarch64-darwin hosts (tynan)
  nix build .#topology.aarch64-darwin.config.output

  # View diagrams
  ls result/  # main.svg (physical) and network.svg (network-centric)
  ```
- **Architecture**: Network includes home LAN (10.1.30.0/24), storage network (10.1.10.0/24), and WAN
- **Visualization**: Auto-generates SVG diagrams showing all hosts, network relationships, and infrastructure

### Salt.nix Resolution
- **Resolved crypto key issues** that were blocking salt-master on nauvoo
- **Root cause**: Issues were outdated (from 2016-2019 Salt versions with libcrypto.so problems)
- **Solution**: Modern Salt 3007.8 + NixOS 25.11 works correctly with proper dependency handling
- **Enabled on**: nauvoo and VMtemplate hosts
- **Removed**: Redundant programs.nh TODO (nh already works via systemPackages)

### Display Manager Migration
- **Transitioned from SDDM to greetd** (tuigreet) for NixOS login management
- New optional module: `hosts/common/optional/greetd.nix` with Hyprland integration
- Implemented on tycho for lightweight, TUI-based login

### Desktop Environment
- **Hyprlock moved to home-manager**: Now configured in `home-manager/common/features/desktop/hyprlock.nix`
- Enhanced lock screen with screenshot blur and styled password input
- Integrated with hypridle for automatic screen locking
- Waybar styling improvements

### CLI Tools & Applications
- **Claude Code**: Integrated AI coding assistant (`home-manager/common/features/cli/claude.nix`)
- **Zed editor**: Added to macOS Homebrew casks
- **Gemini CLI**: Available via both nixpkgs-unstable and Homebrew
- All CLI tools configured in `home-manager/common/features/cli/`

### Optional Modules
- **greetd.nix**: TUI login manager with Hyprland session support
- **salt.nix**: SaltStack master configuration (enabled on nauvoo and VMtemplate)
  - Previous crypto key issues resolved - modern Salt 3007.8 works correctly on NixOS 25.11

## Important Notes

### Flake & Packages
- The flake uses **nixpkgs 25.11 stable** with nixpkgs-unstable overlay available
- **Unstable packages** accessible via `pkgs.unstable` namespace (e.g., `unstable.claude-code`)
- **Custom packages** in `pkgs/`: kubectl-browse-pvc
- **Custom overlays**: additions (custom pkgs), modifications (overrides), unstable-packages, talhelper-overlay

### Secrets Management
- **Fully migrated to opnix** (1Password integration) - agenix removed
- System secrets: Configured per-host in `hosts/<platform>/<hostname>/secrets.nix`
- User secrets: Configured via `opnix_personal.nix` and `opnix_servers.nix`
- **Critical:** Secret names must be camelCase (e.g., `mySecret`, not `my-secret`)
- Legacy .age files preserved in `secrets/` directory for reference only

### Platform-Specific Notes
- **macOS**: Uses Homebrew for apps not available in nixpkgs (configured in hosts/*/homebrew.nix)
- **NixOS**: Uses disko for declarative disk partitioning
- **Desktop**: Hyprland on tycho with greetd/tuigreet login and hyprlock screen lock

### User Configuration
- Color scheme: Tokyo Night Dark (custom base16 scheme)
  - Custom colorscheme module: `modules/home-manager/colorschemes/tokyo-night.nix`
  - Based on Tokyo Night Dark base16 palette from folke/tokyonight.nvim
  - Applied globally via `home-manager/common/global/default.nix`
- Neovim configuration uses nvf (NotAShelf/nvf) with Tokyo Night theme
- Home-manager integrated into both NixOS and Darwin rebuilds
- CLI features auto-imported in `home-manager/common/global/default.nix`

### Theme Details
**Tokyo Night Dark** is applied across:
- **CLI Tools** (all platforms): Neovim, FZF, Bat, Ghostty
- **Desktop** (NixOS only): GTK (Tokyonight-Dark), Icons (Papirus-Dark), Rofi, Hyprland

**Color Palette** (base16):
- Background: `#1a1b26` | Foreground: `#c0caf5`
- Purple: `#bb9af7` | Blue: `#7aa2f7` | Cyan: `#7dcfff`
- Green: `#9ece6a` | Yellow: `#e0af68` | Red: `#f7768e`

To switch theme variants (night/storm/moon), edit `modules/home-manager/colorschemes/tokyo-night.nix`

## Build Status

✅ **All builds validated**
- NixOS configurations: ✅ Working (nauvoo, razerback, tycho)
- Darwin configurations: ✅ Working (barkeith, chetzemoka, donnager, tynan)
- Home-manager configurations: ✅ Working
- Custom packages: ✅ Working (kubectl-browse-pvc)
- Custom overlays: ✅ Working (additions, modifications, unstable-packages, talhelper-overlay)
- Opnix integration: ✅ Fully operational (validated on tycho and tynan)

## Opnix Key Details

**Secret Naming:**
- ✅ Use camelCase: `tailscaleKey`, `databasePassword`, `sshPrivateKey`
- ❌ Don't use kebab-case: `tailscale-key`, `database-password`
- ❌ Don't use snake_case: `tailscale_key`, `database_password`

**Configuration Patterns:**
- **System-level** (NixOS/Darwin): `services.onepassword-secrets`
  - Requires `tokenFile = "/etc/opnix-token"`
  - Requires `users = ["username"]` for group membership
  - Absolute paths required
- **User-level** (home-manager): `programs.onepassword-secrets`
  - No tokenFile needed (uses system token)
  - Relative paths (to home directory)
  - Works on both NixOS and Darwin

**Group Membership:**
Always add users to the `onepassword-secrets` group in system configs:
```nix
services.onepassword-secrets = {
  users = ["deatrin"];  # Critical for persistent access
  # ...
};
```

**Per-Host Configuration:**
- System secrets are configured per-host for flexibility
- Not all hosts need the same secrets
- Example: tycho has tailscale, nauvoo might have different secrets

## TODO

### High Priority
- [x] Add devShells using flake-parts perSystem pattern (completed)

### Medium Priority
- [x] Fix salt.nix crypto key issues on nauvoo host (resolved - issue was outdated)

### Documentation
- [x] Update CLAUDE.md with recent changes (greetd, hyprlock, Claude Code, nh migration)
- [x] Document VMtemplate usage
- [x] Clarify legacy agenix file location

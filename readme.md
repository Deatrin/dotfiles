# dotfiles

Personal NixOS and nix-darwin configuration managing multiple systems with declarative, reproducible setups.

## Overview

This repository uses:
- **Nix Flakes** with **flake-parts** for modular organization
- **NixOS** (3 hosts) and **nix-darwin** (4 hosts) for system configuration
- **home-manager** for user-level configuration (integrated into system rebuilds)
- **opnix** for 1Password secrets management
- **Hyprland** for desktop environments on NixOS hosts
- **Neovim** configured with [nvf](https://github.com/NotAShelf/nvf)
- **Ghostty** terminal across all platforms
- **Dracula** color scheme via nix-colors

## Quick Start

For detailed documentation about the architecture, build commands, and development workflow, see **[CLAUDE.md](CLAUDE.md)**.

For host-specific setup instructions, see the individual README files in the [Hosts](#hosts) section below.

## Build Commands

### NixOS Systems
```bash
sudo nixos-rebuild switch --flake .#<hostname>
# or with nh (recommended)
nh os switch
```

### macOS Systems
```bash
darwin-rebuild switch --flake .#<hostname>
# or with nh (recommended)
nh home switch
```

### Flake Management
```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input <input-name>

# Check flake validity
nix flake check
```

## Hosts

| Host | Platform | Type | User | README |
|------|----------|------|------|--------|
| nauvoo | NixOS (x86_64) | VM | deatrin | [README](hosts/nixos/nauvoo/README.md) |
| razerback | NixOS (x86_64) | Laptop | deatrin | [README](hosts/nixos/razerback/README.md) |
| tycho | NixOS (x86_64) | Laptop | deatrin | [README](hosts/nixos/tycho/README.md) |
| barkeith | macOS (x86_64) | MacBook Pro | ajennex | [README](hosts/darwin/barkeith/README.md) |
| chetzemoka | macOS (aarch64) | MacBook Air | ajennex | [README](hosts/darwin/chetzemoka/README.md) |
| donnager | macOS (x86_64) | iMac Pro | ajennex | [README](hosts/darwin/donnager/README.md) |
| tynan | macOS (aarch64) | MacBook | deatrin | [README](hosts/darwin/tynan/README.md) |

## Structure

- **Root files**
  - [flake.nix](flake.nix) - Minimal orchestrator that imports flake-parts modules
  - [flake.lock](flake.lock) - Lockfile for dependency versions (updated daily via GitHub Actions)
  - [CLAUDE.md](CLAUDE.md) - Comprehensive documentation for development and architecture
- **[flake/](flake/)** - Flake-parts modules for modular flake organization
  - [hosts.nix](flake/hosts.nix) - Single source of truth for all host metadata
  - [lib.nix](flake/lib.nix) - Helper functions (mkNixos, mkDarwin, mkHome)
  - [packages.nix](flake/packages.nix) - perSystem packages module
  - [overlays.nix](flake/overlays.nix) - perSystem overlays with pkgs and pkgs-unstable
  - [nixos.nix](flake/nixos.nix) - NixOS configuration factory
  - [darwin.nix](flake/darwin.nix) - Darwin configuration factory
  - [home-manager.nix](flake/home-manager.nix) - Home-manager configuration factory
- **[home-manager/](home-manager/)** - User-level configuration
  - [common/global/](home-manager/common/global/) - Universal user configuration imported by all users
  - [common/features/](home-manager/common/features/) - Opt-in feature modules
    - [cli/](home-manager/common/features/cli/) - CLI tools (git, zsh, tmux, neovim, etc.)
    - [desktop/](home-manager/common/features/desktop/) - Desktop environment (Hyprland, rofi, theming)
    - [dev/](home-manager/common/features/dev/) - Development environment configurations
    - [kubernetes/](home-manager/common/features/kubernetes/) - Kubernetes tooling (k9s, kubectl)
  - [darwin/](home-manager/darwin/) - macOS user configurations (barkeith.nix, chetzemoka.nix, donnager.nix, tynan.nix)
  - [nixos/](home-manager/nixos/) - NixOS user configurations (deatrin_nauvoo.nix, deatrin_razerback.nix, deatrin_tycho.nix)
- **[hosts/](hosts/README.md)** - Machine-level configuration
  - [common/darwin/](hosts/common/darwin/) - Shared macOS configuration (defaults, homebrew)
  - [common/nixos/](hosts/common/nixos/) - Shared NixOS configuration (locale, nix, openssh, tailscale)
  - [common/optional/](hosts/common/optional/) - Optional modules (docker, podman, fonts, plex, jellyseerr)
  - [common/containers/](hosts/common/containers/) - Docker compose configurations
  - [darwin/](hosts/darwin/) - Per-host macOS configurations (barkeith, chetzemoka, donnager, tynan)
  - [nixos/](hosts/nixos/) - Per-host NixOS configurations (nauvoo, razerback, tycho)
  - [VMtemplate/](hosts/VMtemplate/) - Template for VM setup
- **[modules/](modules/)** - Custom NixOS and home-manager modules
- **[overlays/](overlays/)** - Custom package overlays including unstable packages
- **[pkgs/](pkgs/)** - Custom packages not available in nixpkgs
- **[backup/](backup/)** - Migration artifacts and old configurations (e.g., agenix migration)
- **[keys/](keys/)** - Public GPG keys
- **[wallpapers/](wallpapers/)** - Default wallpapers

## References

- Not gonna lie most of this was made possible by stumbling on [billimek's](https://github.com/billimek/dotfiles/tree/master) dotfiles while I was trying to figure out how to get [nvf](https://github.com/NotAShelf/nvf) to work with nix darwin
- Shoutouts to code search on github wayyyyy better than any google search to find examples
- Nix is a rabbit hole once I found I could merge both nixOS and nix-darwin files this was the outcome

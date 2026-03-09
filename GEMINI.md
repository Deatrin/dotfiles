# Gemini Context: Dotfiles Redux

This `GEMINI.md` provides context, architectural details, and operational instructions for this Nix-based dotfiles repository. It is designed to assist AI agents in understanding and working with this codebase.

## 1. Project Overview

This repository is a **multi-system Nix configuration** managing both **NixOS** and **macOS (nix-darwin)** machines. It leverages **Nix Flakes** for reproducibility and **Home Manager** for user-level configuration.

**Key Technologies:**
*   **Core:** Nix Flakes, `flake-parts` (for modular organization).
*   **Systems:** NixOS (Linux), nix-darwin (macOS).
*   **User Config:** Home Manager (integrated into system rebuilds).
*   **Secrets:** `opnix` (1Password integration). **Note:** `agenix` has been removed.
*   **Editors:** Neovim (via `nvf`), VS Code (via `nix-ld` support).
*   **Terminal:** Ghostty (cross-platform), tmux.
*   **Desktop (Linux):** Hyprland.
*   **Login/Lock:** Greetd (tuigreet), Hyprlock, Hypridle.
*   **Shell:** Zsh, Starship/Oh-My-Posh.

## 2. Architecture

The repository follows a modular "flake-parts" architecture, moving away from a monolithic `flake.nix`.

### Directory Structure
*   **`flake.nix`**: Minimal entry point. Imports modules from `flake/`.
*   **`flake/`**: Contains the logic for generating system configurations.
    *   `hosts.nix`: **The Single Source of Truth.** Defines all hosts, users, and their systems.
    *   `nixos.nix` / `darwin.nix`: Factories that generate configurations based on `hosts.nix`.
*   **`hosts/`**: Machine-specific system configurations.
    *   `common/`: Shared configs (e.g., `hosts/common/nixos/openssh.nix`).
    *   `nixos/<hostname>/` & `darwin/<hostname>/`: Host-specific entry points.
*   **`home-manager/`**: User-specific configurations.
    *   `common/`: Shared features (e.g., `cli`, `desktop`, `dev`).
    *   `nixos/` & `darwin/`: User entry points (e.g., `deatrin_tycho.nix`).
*   **`modules/`**: Custom NixOS/Home Manager modules.
*   **`pkgs/`**: Custom packages overlaid onto `nixpkgs`.

### Configuration Flow
1.  `flake.nix` loads.
2.  `flake/hosts.nix` is read to identify targets.
3.  `flake/{nixos,darwin}.nix` factories build the system configurations.
4.  Hosts import common modules from `hosts/common` and feature modules.
5.  Home Manager is instantiated as a module within the system configuration.

## 3. Operational Commands

### Building & Applying Changes
The `nh` tool is the recommended way to apply configurations.

**NixOS:**
```bash
nh os switch
# Fallback: sudo nixos-rebuild switch --flake .#<hostname>
```

**macOS (Darwin):**
```bash
nh home switch
# Fallback: darwin-rebuild switch --flake .#<hostname>
```

### Flake Management
```bash
nix flake update             # Update all inputs
nix flake check              # Verify flake validity
```

## 4. Development Conventions

### Secrets Management (Opnix)
*   **Tool:** `opnix` is used to integrate 1Password.
*   **Location:**
    *   **System Secrets:** `hosts/<os>/<hostname>/secrets.nix`.
    *   **User Secrets:** `home-manager/common/features/cli/opnix_{personal,servers}.nix`.
*   **Convention:** Secret keys **MUST** use `camelCase` (e.g., `tailscaleKey`, not `tailscale-key`).
*   **Deployment:** Secrets are provisioned automatically during system rebuilds if the machine is authenticated with 1Password.

### Adding a New Host
1.  **Define:** Add the host entry to `flake/hosts.nix` (`nixosHosts` or `darwinHosts`).
2.  **Create:** Create the directory `hosts/<os>/<hostname>` with a `default.nix`.
3.  **Hardware:** For NixOS, generate `hardware-configuration.nix`.
4.  **Secrets:** Create `secrets.nix` if needed.

### Code Style
*   Prefer `flake-parts` modules over traditional imports where applicable.
*   Keep host-specific config minimal; move shared logic to `hosts/common` or `home-manager/common`.

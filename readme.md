# Dotfile Storage

Leveraging Nix with nix-darwin or nixOS with home manager to apply desiered configuration to machines

## Structure

- Root Folder
  - [flake.nix](flake.nix) (The top level flake for rebuilding via nixos-rebuild/darwin-rebuild/home-manager)
  - [flake.lock](flake.lock) (The flake lockfile for current state updated daily via [github action](.github/workflows/main.yml))
  - [home-manager](home-manager) (User level configuration per machine via home-manager)
    - [common](home-manager/common/) (Top level folder holding the common configurations)
      - [features](home-manager/common/features/) (Holds various feature configs split into categories)
        - [cli](home-manager/common/features/cli/) (Holds the common configuration for CLI tools)
        - [desktop](home-manager/common/features/desktop/) (Holds the common configuration for Desktop maanger in nixOS)
        - [dev](home-manager/common/features/dev/) (Holds dev tools configuration use this to turn on things like go)
        - [kubrenetes](home-manager/common/features/kubernetes/) (Holds Kubernetes tools configuration)
      - [global](home-manager/common/global/) (Holds global configuration for everything)
    - [barkeith](home-manager/barkeith.nix) (Holds the home-manager config for [barkeith](/hosts/barkeith/README.md))
    - [chetzemoka](home-manager/chetzemoka.nix) (Holds the home-manager config for [chetzemoka](/hosts/chetzemoka/README.md))
    - [deatrin_nauvoo](home-manager/deatrin_nauvoo.nix) (Holds the home-manager config for [nauvoo](/hosts/nauvoo/README.md))
    - [deatrin_razerback](home-manager/deatrin_razerback.nix) (Holds the home-manager config for [razerback](/hosts/razerback/README.md))
    - [donnager](home-manager/donnager.nix) (Holds the home-manager config for [donnager](/hosts/donnager/README.md))
  - [hosts](/hosts/README.md) (Definition of hosts both macOS and nixOS)
    - [common](/hosts/common/) (Role definitions)
    - [barkeith](/hosts/barkeith/README.md) (macOS (Intel Macbook Pro) configuration)
    - [chetzemoka](/hosts/chetzemoka/README.md) (macOS (m2 Macbook Air) configuration)
    - [donnager](/hosts/donnager/README.md) (macOS (iMac Pro) configuration)
    - [nauvoo](/hosts/nauvoo/README.md) (nixOS (VM) configuration)
    - [razerback](/hosts/razerback/README.md) (nixOS (Percision 5760) configruation)
    - [tachi](/hosts/tachi/README.md) (nixOS (Optiplex 5050) configuration)
    - [tycho](/hosts/tycho/README.md) (nixOS (T14 G3) configuration)
  - [keys](/keys/) (Stores public keys needed for GPG)
  - [modules](/modules/) (Custom nixOS and home-manager modules)
  - [overlays](overlays) (Custom overlays)
  - [pkgs](pkgs) (Custom packages used for things not found in nixpkgs)
  - [wallpapers](wallpapers) (Stores my default wallpaper)

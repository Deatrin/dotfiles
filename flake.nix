{
  description = "Deatrin's MultiOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Pinned to the last nixpkgs rev shipping podman 5.8.6 — 5.8.7+ broke
    # CopyToContainer archive extraction for paths crossing an absolute
    # symlink (e.g. /var/run -> /run), which breaks the Forgejo Actions
    # runner on nauvoo (every job fails at actions/checkout). Drop once
    # nixpkgs picks up a podman release with the buildah copier fix.
    nixpkgs-podman-5-8-6.url = "github:nixos/nixpkgs/c27cdad491a991b11ed731760aa2ef8db0cb0410";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld-vscode = {
      url = "github:scottstephens/nix-ld-vscode/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel.url = "github:jas-singhfsu/hyprpanel";
    hyprsettings.url = "github:acropolis914/hyprsettings";
    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    talhelper.url = "github:budimanjojo/talhelper";
    opnix.url = "github:brizzbuzz/opnix";
    nvf.url = "github:notashelf/nvf";
    nix-topology.url = "github:oddlama/nix-topology";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports =
        [
          ./flake/lib.nix
          ./flake/aspects.nix
          ./flake/overlays.nix
          ./flake/packages.nix
          ./flake/devshells.nix
          ./flake/nixos.nix
          ./flake/darwin.nix
          ./flake/topology.nix
          (inputs.import-tree ./aspects)
        ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake = {
        nixosModules = import ./modules/nixos;
        homeManagerModules = import ./modules/home-manager;
      };
    };
}

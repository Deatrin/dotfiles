{
  description = "Deatrin's MultiOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
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
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./flake/lib.nix
        ./flake/overlays.nix
        ./flake/packages.nix
        ./flake/devshells.nix
        ./flake/nixos.nix
        ./flake/darwin.nix
        ./flake/home-manager.nix
        ./flake/topology.nix
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

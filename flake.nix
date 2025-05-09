{
  description = "Deatrin's MultiOS Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nh_darwin.url = "github:ToyVo/nh_plus";

    # for VSCode remote-ssh
    nix-ld-vscode = {
      url = "github:scottstephens/nix-ld-vscode/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    talhelper.url = "github:budimanjojo/talhelper";
    opnix.url = "github:brizzbuzz/opnix";
    nvf.url = "github:notashelf/nvf";
  };
  outputs = 
  {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nixpkgs-unstable,
    ...
  }@inputs:
  let 
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
    ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkNixos = 
      modules:
      nixpkgs.lib.nixosSystem {
        inherit modules;
        specialArgs = {
          inherit inputs outputs;
        };
      };
      mkHome =
      modules: pkgs:
      home-manager.lib.homeManagerConfiguration {
        inherit modules pkgs;
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };
  in 
  {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      # packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
  }
}
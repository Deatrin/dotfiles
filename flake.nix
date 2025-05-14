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

    nh_darwin.url = "github:ToyVo/nh_plus";

    # for VSCode remote-ssh
    nix-ld-vscode = {
      url = "github:scottstephens/nix-ld-vscode/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpanel.url = "github:jas-singhfsu/hyprpanel";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    talhelper.url = "github:budimanjojo/talhelper";
    opnix.url = "github:brizzbuzz/opnix";
    nvf.url = "github:notashelf/nvf";
  };
  outputs = {
    self,
    disko,
    nixpkgs,
    home-manager,
    nix-darwin,
    nixpkgs-unstable,
    ...
  } @ inputs: let
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

    mkNixos = modules:
      nixpkgs.lib.nixosSystem {
        inherit modules;
        specialArgs = {
          inherit inputs outputs;
        };
      };
    mkHome = modules: pkgs:
      home-manager.lib.homeManagerConfiguration {
        inherit modules pkgs;
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };
  in {
    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs {pkgs = nixpkgs.legacyPackages.${system};});

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nauvoo = mkNixos [./hosts/nauvoo];
      razerback = mkNixos [./hosts/razerback];
      tycho = mkNixos [./hosts/tycho];
      tachi = mkNixos [./hosts/tachi];
    };

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#<hostname>
    darwinConfigurations = {
      # I am a intel based macbook pro
      barkeith = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-darwin";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/barkeith
          # nh_darwin.nixDarwinModules.default
        ];
      };
      # I am a m2 macbook air
      chetzemoka = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        };
        modules = [./hosts/chetzemoka];
      };
      # I am a imac pro
      donnager = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-darwin";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/donnager
          # nh_darwin.nixDarwinModules.default
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # "nix@nas" = mkHome [ ./home-manager/nix_nas.nix ] nixpkgs.legacyPackages."x86_64-linux";
      # NixOS

      "ajennex@nauvoo" = mkHome [./home-manager/deatrin_nauvoo.nix] nixpkgs.legacyPackages."x86_64-linux";
      "ajennex@razerback" = mkHome [./home-manager/deatrin_razerback.nix] nixpkgs.legacyPackages."x86_64-linux";
      "ajennex@tycho" = mkHome [./home-manager/deatrin_tycho.nix] nixpkgs.legacyPackages."x86_64-linux";

      # Macs
      "ajennex@barkeith" =
        mkHome [
          ./home-manager/barkeith
        ]
        nixpkgs.legacyPackages."x86_64-darwin";
      "ajennex@chetzemoka" =
        mkHome [
          ./home-manager/chetzemoka.nix
        ]
        nixpkgs.legacyPackages."aarch64-darwin";
      "ajennex@donnager" =
        mkHome [
          ./home-manager/donnager.nix
        ]
        nixpkgs.legacyPackages."x86_64-darwin";
    };
  };
}

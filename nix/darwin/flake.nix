{
  description = "Personal Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { 
    self, 
    nix-darwin, 
    nixpkgs,
    nixpkgs-unstable,
    nix-homebrew, 
    home-manager,
    ...
    } @ inputs: let
      add-unstable-packages = final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-darwin";
        };
      };
      username = "ajennex";
      configuration = { pkgs, lib, config, ... }: {
        
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
        add-unstable-packages
      ];

        # Application install section
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [
          pkgs.alacritty
          pkgs.alacritty-theme
          pkgs.archi
          pkgs.discord
          pkgs.eza
          pkgs.git
          pkgs.mkalias
          pkgs.neovim
          pkgs.obsidian
          pkgs.raycast
          pkgs.spotify
          pkgs.tmux
          pkgs.vscode
          ];
        
        homebrew = {
          enable = true;
          brews = [
            "k9s"
            "mas"
            "wireshark"
          ];
          casks = [
            "airtool"
            "bartender"
            "brave-browser"
            # "displaylink"
            "dropbox"
            "flux"
            "github"
            "jetbrains-toolbox"
            "lens"
            "logseq"
            "rekordbox"
            "mixed-in-key"
            "raindropio"
            "rectangle-pro"
            "remote-desktop-manager"
            "serial"
            "wifi-explorer-pro"
            "vlc"
            "vmware-fusion"
            "yubico-yubikey-manager"
          ];
          masApps = {
            "1 Password 7" = 1333542190;
            "Spark Classic" = 1176895641;
            "Termius" = 1176074088;
            "Yoink" = 457622435;
            "Yubico Authenticator" =1497506650;
          };
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

        # Add fonts
        fonts.packages = [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
        # Make alias's for nix installed apps
        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in
          pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';
        
        # System Settings
        system.defaults = {
          # Dock Options
          dock.autohide = true;
          dock.minimize-to-application = true;
          dock.mouse-over-hilite-stack = true;
          dock.mru-spaces = false;
          dock.show-recents = false;
          dock.showhidden = true;
          dock.persistent-apps = [
            "/Applications/Brave Browser.app"
            "/Applications/Raindrop.io.app"
            "${pkgs.obsidian}/Applications/Obsidian.app"
            "${pkgs.discord}/Applications/Discord.app"
            "/Applications/Termius.app"
            "${pkgs.spotify}/Applications/Spotify.app"
            "${pkgs.vscode}/Applications/Visual Studio Code.app"
            "${pkgs.alacritty}/Applications/Alacritty.app"
            "/System/Applications/System Settings.app"
          ];

          # Finder Options
          finder.FXPreferredViewStyle = "clmv";
          finder._FXSortFoldersFirst = true;

          # Login Options
          loginwindow.GuestEnabled  = false;

          # Menu Bar Clock Options
          menuExtraClock.ShowDate = 1;
          menuExtraClock.ShowDayOfWeek = true;

          # Global Domain Options
          NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
          NSGlobalDomain."com.apple.swipescrolldirection" = false;
          NSGlobalDomain.AppleInterfaceStyle = "Dark";
          NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
          NSGlobalDomain.PMPrintingExpandedStateForPrint = true;

          # Screen Cap Settings
          screencapture.location = "/Users/ajennex/Pictures/Screenshots";

          # Screen Lock Options
          screensaver.askForPassword = true;
          screensaver.askForPasswordDelay = 10;
          # Trackpad Settings
          trackpad.Clicking = true;
        };
        users.users.ajennex = {
          name = username;
          home = "/Users/ajennex";
        };

        nix.configureBuildUsers= true;
        
        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;  # default shell on catalina

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "x86_64-darwin";
      };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."intel" = nix-darwin.lib.darwinSystem {
      modules = [ 
      configuration
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          # User owning the Homebrew prefix
          user = "ajennex";
          # Auto migrates an exisiting install if needed
          autoMigrate = true;
        };
      }
      home-manager.darwinModules.home-manager
      {
        # config
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.ajennex = import ./home.nix;
      }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}

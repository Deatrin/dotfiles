{
  description = "Personal Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.url = "git+https://github.com/zhaofengli/nix-homebrew?ref=refs/pull/71/merge";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
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
        # system = "aarch64-darwin";
      };
    };
    username = "ajennex";
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
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
        pkgs.alejandra
        pkgs.archi
        pkgs.discord
        pkgs.eza
        pkgs.fluxcd
        pkgs.git
        pkgs.gnupg
        pkgs.mkalias
        pkgs.neofetch
        pkgs.nixd
        pkgs.nixos-anywhere
        pkgs.obsidian
        pkgs.pinentry_mac
        pkgs.spotify
        pkgs.unstable.tmux
        pkgs.vscode
      ];

      homebrew = {
        enable = true;
        brews = [
          # "cloudflared" # Only really needed when we need to create new tunnels for kube
          "direnv"
          "go-task"
          "k9s"
          "mas"
          "neovim"
          "tenv"
          "wireshark"
        ];
        casks = [
          "1password"
          "1password-cli"
          "airtool"
          "bartender"
          "brave-browser"
          "displaylink"
          "docker"
          "dropbox"
          "flux"
          "github"
          "jetbrains-toolbox"
          "lens"
          "logseq"
          "raycast"
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
          "Spark Classic" = 1176895641;
          "TickTick" = 966085870;
          "Termius" = 1176074088;
          "Yoink" = 457622435;
          "Yubico Authenticator" = 1497506650;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Add fonts
      fonts.packages = [
        (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
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
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      # System Settings
      system.defaults = {
        # Dock Options
        dock.autohide = true;
        dock.minimize-to-application = false;
        dock.mouse-over-hilite-stack = true;
        dock.mru-spaces = false;
        dock.show-recents = false;
        dock.showhidden = true;
        dock.persistent-apps = [
          "/Applications/TickTick.app"
          "/Applications/Spark.app"
          "/System/Applications/Messages.app"
          "/Applications/Google Chrome.app"
          "/Applications/Brave Browser.app"
          "/Applications/Raindrop.io.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "${pkgs.discord}/Applications/Discord.app"
          "/Applications/Termius.app"
          "${pkgs.spotify}/Applications/Spotify.app"
          "/Applications/1Password.app"
          "/Applications/Yubico Authenticator.app"
          "/Applications/Remote Desktop Manager.app"
          "/Applications/Serial.app"
          "${pkgs.vscode}/Applications/Visual Studio Code.app"
          "${pkgs.alacritty}/Applications/Alacritty.app"
          "/Applications/Docker.app/Contents/MacOS/Docker Desktop.app"
          "/System/Applications/System Settings.app"
        ];

        # Finder Options
        finder.FXPreferredViewStyle = "clmv";
        finder._FXSortFoldersFirst = true;
        finder.ShowHardDrivesOnDesktop = true;

        # Login Options
        loginwindow.GuestEnabled = false;

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

      nix.configureBuildUsers = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
      # nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."main" = nix-darwin.lib.darwinSystem {
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
    darwinPackages = self.darwinConfigurations."main".pkgs;
  };
}

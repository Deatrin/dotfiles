{
  inputs,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./homebrew.nix
    inputs.opnix.darwinModules.default
  ];
  #package config
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      # false until https://github.com/NixOS/nix/issues/11002 is truly resolved
      # sandbox = false;

      substituters = [
        "https://cache.nixos.org/" # official binary cache (yes the trailing slash is really neccacery)
        "https://nix-community.cachix.org" # nix-community cache
        "https://nixpkgs-unfree.cachix.org" # unfree-package cache
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];
    };
  };

  environment = {
    systemPackages = [
      pkgs.alejandra
      pkgs.git
      pkgs.home-manager
      inputs.nh_darwin.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  programs = {
    zsh.enable = true;
    # nix-index.enable = true;
    # TODO: Uncomment when programs.nh becomes available in nix-darwin
    # nh = {
    #   enable = true;
    #   clean.enable = true;
    # };
  };

  # add nerd fonts
  fonts.packages = [
    pkgs-unstable.monaspace
    pkgs-unstable.nerd-fonts.monaspace
    pkgs-unstable.nerd-fonts.symbols-only
    pkgs-unstable.nerd-fonts.jetbrains-mono
  ];

  system.keyboard = {
    enableKeyMapping = true;
  };
  system.defaults = {
    menuExtraClock = {
      ShowDayOfWeek = true;
      ShowDayOfMonth = true;
      ShowAMPM = false;
    };

    # control center
    controlcenter = {
      BatteryShowPercentage = true; # show battery percentage in control center
    };

    # dock options
    dock = {
      autohide = true; # autohide task bar
      tilesize = 64; # set taskbar size
      minimize-to-application = false; # do not minimze to application
      mouse-over-hilite-stack = true; # hilgiht files and folder in stacks
      mru-spaces = false; # turn off rearrange on recent user
      show-recents = false; # show recents on dock
      showhidden = true; # make hidden apps translusent
      wvous-br-corner = 1; # sets bottom right corner to nothing in hot corners
      wvous-bl-corner = 1; # sets bottom left corner to nothing in hot corners
      wvous-tl-corner = 1; # sets top left corner to nothing in hot corners
      wvous-tr-corner = 1; # sets top right corner to nothing in hot corners
    };
    # finder options
    finder = {
      AppleShowAllExtensions = true; # show all file extensions
      FXEnableExtensionChangeWarning = false; # disable warning when changing file extensions
      _FXShowPosixPathInTitle = false; # show full path in title bar
      _FXSortFoldersFirst = true; # shows folders first in finder
      FXPreferredViewStyle = "clmv"; # column view
      FXDefaultSearchScope = "SCcf"; # search current folder by default
      NewWindowTarget = "Computer";
      ShowHardDrivesOnDesktop = true; # shows the hard disk on the desktop
      ShowStatusBar = true; # show status bar
      ShowPathbar = false; # show path bar
    };

    # trackpad
    trackpad = {
      Clicking = true;
    };

    # software updates
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    # other options
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # set dark mode
      "com.apple.swipescrolldirection" = false; # set natural scrolling to the _correct_ value
      # "com.apple.mouse.tapBehavior" = 1; # sets tap to click to on

      # set key repeat to be faster
      InitialKeyRepeat = 18; # default: 68
      KeyRepeat = 1; # default: 6

      # disable some auto-correct behaviors
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      # NSAutomaticPeriodSubstitutionEnabled = false;
      # NSAutomaticQuoteSubstitutionEnabled = false;
      # NSAutomaticSpellingCorrectionEnabled = false;

      # Make a feedback sound when the system volume changed. This setting accepts the integers 0 or 1. Defaults to 1
      "com.apple.sound.beep.feedback" = 1;

      # expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # expand print panel by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };

    # screen lock options
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 10;
    };

    WindowManager = {
      EnableTiledWindowMargins = false; # disable tiled window margins
    };

    CustomUserPreferences = {
      # Disable Creation of Metadata Files on Network Volumes
      "com.apple.desktopservices".DSDontWriteNetworkStores = true;
      # Disable Creation of Metadata Files on USB Volumes
      "com.apple.desktopservices".DSDontWriteUSBStores = true;
    };
  };

  # Add flake support and apple silicon stuff
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-platforms = aarch64-darwin x86_64-darwin
  '';

  # Use touch ID for sudo auth
  security.pam.services.sudo_local.touchIdAuth = true;

  # Set sudo timestamp timeout
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';
}

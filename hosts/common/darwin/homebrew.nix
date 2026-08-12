{
  config,
  pkgs,
  ...
}: {
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "none"; # brew bundle --cleanup now requires --force-cleanup; nix-darwin hasn't added the flag yet
    taps = [
      {
        name = "nikitabobko/tap"; # aerospace lives here; Homebrew 6.0 requires explicit trust
        trusted = true;
      }
    ];
    brews = [
      "aqua" # Declarative cli version management
      "cask"
      "mas" # Mac App Store CLI (required for masApps)
      "jj" # jujutsu
      "pyenv" # Python version management
      "sops" # Secrets
      "tenv" # Terraform/opentofu version management
    ];
    casks = [
      "1password" # GUI 1pass
      "1password-cli" # need to install CLI via brew to make biometric unlock work with GUI app
      "aerospace" # i3 like window manager
      "antigravity-cli" # gemini-cli's replacement
      "bambu-studio" # silcer for 3d printer
      "bartender" # cleans up menu bar
      "brave-browser" # perfered browser
      "cyberduck"
      "discord" # chat
      # "docker" # you already know
      "dropbox" # self id
      "flux-app" # make my screen red at night
      "lens" # k8s tool
      "ghostty" # so hot right now
      "google-chrome" # le chrome
      "logi-options+" # mouse stuff
      "microsoft-office" # Office just in case
      "nvidia-geforce-now" # this is a lil self explanatory
      "obsidian" # note taking app
      "OrbStack" # docker and linux virt
      "qlmarkdown" # markdown preview in quicklook
      "raindropio" # raindrop bookmark manager
      "raycast" # spotlight replacement
      "rectangle-pro" # key controlled snap feature
      "remote-desktop-manager" # devolutions rdm
      "sanesidebuttons" # enable side buttons on mouse
      "steam" # you already know yo
      "serial" # serial connection application
      "spotify" # music
      "visual-studio-code" # code editor
      "vlc" # video player
      "zed" # zed editor
    ];
    masApps = {
      "GrandPerspective" = 1111570163;
      "Spark Mail - AI Email & Inbox" = 6445813049;
      "Tailscale" = 1475387142;
      "Termius" = 1176074088;
      "WireGuard" = 1451685025;
      "Yoink" = 457622435;
      "Yubico Authenticator" = 1497506650;
    };
  };
}

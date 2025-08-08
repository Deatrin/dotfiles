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
    onActivation.cleanup = "zap";
    taps = [
      "nikitabobko/tap"
      "charmbracelet/tap" # for charm cli tools
    ];
    brews = [
      "aqua" # Declarative cli version management
      "cask"
      "pyenv" # Python version management
      "sops" # Secrets
      "tenv" # Terraform/opentofu version management
    ];
    casks = [
      "1password" # GUI 1pass
      "1password-cli" # need to install CLI via brew to make biometric unlock work with GUI app
      "bambu-studio" # silcer for 3d printer
      "bartender" # cleans up menu bar
      "brave-browser" # perfered browser
      "discord" # chat
      # "docker" # you already know
      "dropbox" # self id
      "flux" # make my screen red at night
      "jetbrains-toolbox" # insatlls jetbrains toolbox to install other jetbrains stuff
      "lens" # k8s tool
      "ghostty" # so hot right now
      "google-chrome" # le chrome
      "logi-options+" # mouse stuff
      "microsoft-office" # Office just in case
      "notion" # notetaking app
      "obsidian" # note taking app
      "OrbStack" # docker and linux virt
      "qlmarkdown" # markdown preview in quicklook
      "raindropio" # raindrop bookmark manager
      "raycast" # spotlight replacement
      "rectangle-pro" # key controlled snap feature
      "remote-desktop-manager" # devolutions rdm
      "sanesidebuttons" # enable side buttons on mouse
      "serial" # serial connection application
      "slack" # Work
      "spotify" # music
      "visual-studio-code" # code editor
      "vlc" # video player
    ];
    masApps = {
      "Canary Mail App" = 1236045954;
      "Tailscale" = 1475387142;
      "Termius" = 1176074088;
      "TickTick" = 966085870;
      "WireGuard" = 1451685025;
      "Yoink" = 457622435;
      "Yubico Authenticator" = 1497506650;
    };
  };
}

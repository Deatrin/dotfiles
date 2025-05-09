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
    brews = [
      "cask"
      "tenv"
    ];
    # taps = [
    #   "homebrew/bundle"
    #   "homebrew/cask-fonts"
    #   "homebrew/services"
    # ];
    casks = [
      "1password"
      "1password-cli" # need to install CLI via brew too to make biometric unlock work with GUI app
      "bartender" # cleans up menu bar
      "brave-browser" # perfered browser
      "discord" # chat
      "docker" # you already know
      "dropbox" # self id
      "flux" # make my screen red at night
      "jetbrains-toolbox" # insatlls jetbrains toolbox to install other jetbrains stuff
      "lens" # k8s tool
      "ghostty" # so hot right now
      "karabiner-elements" # keyboard remapping
      "notion" # notetaking app
      "qlmarkdown" # markdown preview in quicklook
      "raindropio" # raindrop bookmark manager
      "raycast" # spotlight replacement
      "rectangle-pro" # key controlled snap feature
      "sanesidebuttons" # enable side buttons on mouse
      "serial" # serial connection application
      "spotify" # music
      "shottr" # screenshot tool
      "visual-studio-code" # code editor
      "vlc" # video player
    ];
    masApps = {
      "Tailscale" = 1475387142;
      "Termius" = 1176074088;
      "TickTick" = 966085870;
      "Yoink" = 457622435;
      "Yubico Authenticator" = 1497506650;
    };
  };
}

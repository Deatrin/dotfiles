{
  pkgs,
  ...
}: {
  imports = [
    ./fzf.nix
    ./neofetch.nix
    ./ohmyposh.nix
    ./tmux.nix
    ./zsh.nix
  ];
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraOptions = [ "-l" "--icons" "--git" "-a" ];
  };

  programs.bat = {enable = true;};
  
  home.packages = with pkgs; [
    brave
    brightnessctl
    clipman
    coreutils
    distrobox
    # eww
    fd
    htop
    httpie
    hyprpaper
    jq
    libsForQt5.qtstyleplugins
    nwg-look
    pamixer
    pavucontrol
    pcmanfm
    procs
    libsForQt5.qt5ct
    qt6.qtwayland
    ripgrep
    tldr
    usbutils
    xdg-utils
    zip
  ];
}

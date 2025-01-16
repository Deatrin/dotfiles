{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.rofi = with pkgs; {
    enable = true;
    package = rofi.override {
      plugins = [
        rofi-calc
        rofi-emoji
        stable.rofi-file-browser
      ];
    };
    pass = {
      enable = true;
      package = rofi-pass-wayland;
    };
    terminal = "\${pkgs.kitty}/bin/kitty";
    font = "Fira Code";
    extraConfig = {
      show-icons = true;
      disable-history = false;
      modi = "drun,calc,emoji,filebrowser";
      kb-primary-paste = "Control+V,Shift+Insert";
      kb-secondary-paste = "Control+v,Insert";
    };
    theme = "dracula";
  };
}

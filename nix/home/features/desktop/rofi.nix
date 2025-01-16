{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file.".config/rofi/themes/dracula.rasi".text = ''
    * {
        bg-col:  #282a36;
        bg-col-light: #44475a;
        border-col: #44475a;
        selected-col: #44475a;
        blue: #bd93f9;
        fg-col: #f8f8f2;
        fg-col2: #ffffff;
        grey: #6272a4;
        width: 600;
      }
  '';

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
    terminal = "\${pkgs.alacritty}/bin/alacritty";
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

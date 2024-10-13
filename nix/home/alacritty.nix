{
  pkgs,
  ...
}: {
  enable = true;
  package = pkgs.unstable.alacritty;

  settings = {
    window = {
      padding = {
        x = 4;
        y = 8;
      };
      decorations = "Buttonless";
      opacity = 0.5;
      blur = true;
      startup_mode = "Maximized";
      title = "Alacritty";
      dynamic_title = true;
      decorations_theme_variant = "None";
    };

    import = [
      "${pkgs.alacritty-theme}/tokyo-night.toml"
    ];

    font = let
      jetbrainsMono = style: {
        family = "JetBrainsMono Nerd Font";
        inherit style;
      };
    in {
      size = 12;
      normal = jetbrainsMono "Regular";
      bold = jetbrainsMono "Bold";
      italic = jetbrainsMono "Italic";
      bold_italic = jetbrainsMono "Bold Italic";
    };

    cursor = {
      style = "Underline";
    };

    env = {
      TERM = "xterm-256color";
    };

    live_config_reload = true;
  };
}
{pkgs, ...}: {
  enable = true;
  # package = pkgs.unstable.alacritty;

  settings = {
    window = {
      padding = {
        x = 4;
        y = 8;
      };
      decorations = "Full";
      opacity = 0.5;
      blur = true;
      startup_mode = "Windowed";
      title = "Alacritty";
      dynamic_title = true;
      decorations_theme_variant = "None";
    };

    general.import = [
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

    general.live_config_reload = true;
  };
}

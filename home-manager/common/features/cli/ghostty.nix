{
  pkgs,
  lib,
  ...
}: {
  # On Linux: Use the programs.ghostty module with the package
  programs.ghostty = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.unstable.ghostty;
    settings = {
      theme = "tokyo-night";
      font-family = [
        "Monaspace Neon"
        "Symbols Nerd Font Mono"
      ];
      font-size = 12;

      clipboard-trim-trailing-spaces = true;
      copy-on-select = true;

      keybind = [
        "super+right=next_tab"
        "super+left=previous_tab"
        "super+`=toggle_quick_terminal"
        "shift+page_up=scroll_page_up"
        "shift+page_down=scroll_page_down"
      ];

      # Window settings
      background-opacity = "0.8";
      background-blur = true;
      quit-after-last-window-closed = true;
      window-save-state = "always";
      window-theme = "ghostty";

      # Shell integration
      shell-integration = "detect";
      shell-integration-features = "cursor,sudo,title";
    };

    themes = {
      tokyo-night = {
        background = "#1a1b26";
        foreground = "#c0caf5";
        cursor-color = "#c0caf5";
        cursor-text = "#1a1b26";
        selection-foreground = "#c0caf5";
        selection-background = "#33467c";
        palette = [
          "0=#15161e"
          "1=#f7768e"
          "2=#9ece6a"
          "3=#e0af68"
          "4=#7aa2f7"
          "5=#bb9af7"
          "6=#7dcfff"
          "7=#a9b1d6"
          "8=#414868"
          "9=#f7768e"
          "10=#9ece6a"
          "11=#e0af68"
          "12=#7aa2f7"
          "13=#bb9af7"
          "14=#7dcfff"
          "15=#c0caf5"
        ];
      };
    };
  };

  # On macOS: Use raw config files (ghostty package not yet available for Darwin)
  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    ".config/ghostty/config".text = ''
      clipboard-trim-trailing-spaces = true
      copy-on-select = clipboard

      font-family = "Monaspace Neon"
      font-family = "Symbols Nerd Font Mono"
      font-size = 14

      keybind = shift+page_down=scroll_page_down
      keybind = shift+page_up=scroll_page_up
      keybind = super+`=toggle_quick_terminal
      keybind = super+left=previous_tab
      keybind = super+right=next_tab

      macos-auto-secure-input = true
      macos-icon = holographic
      macos-icon-frame = aluminum
      macos-icon-ghost-color = #7aa2f7
      macos-icon-screen-color = #7aa2f7
      macos-option-as-alt = true
      macos-secure-input-indication = true
      macos-titlebar-style = tabs

      background-opacity = 0.8
      background-blur = true

      quit-after-last-window-closed = true
      shell-integration = detect
      shell-integration-features = cursor,sudo,title

      theme = tokyo-night

      window-save-state = always
      window-theme = ghostty
    '';

    ".config/ghostty/themes/tokyo-night".text = ''
      palette = 0=#15161e
      palette = 1=#f7768e
      palette = 2=#9ece6a
      palette = 3=#e0af68
      palette = 4=#7aa2f7
      palette = 5=#bb9af7
      palette = 6=#7dcfff
      palette = 7=#a9b1d6
      palette = 8=#414868
      palette = 9=#f7768e
      palette = 10=#9ece6a
      palette = 11=#e0af68
      palette = 12=#7aa2f7
      palette = 13=#bb9af7
      palette = 14=#7dcfff
      palette = 15=#c0caf5
      background = #1a1b26
      foreground = #c0caf5
      cursor-color = #c0caf5
      cursor-text = #1a1b26
      selection-foreground = #c0caf5
      selection-background = #33467c
    '';
  };
}

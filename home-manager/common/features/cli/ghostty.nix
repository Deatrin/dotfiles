{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.unstable.ghostty;
    settings = {
      theme = "dracula";
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
      macos-auto-secure-input = true;
      macos-icon = "custom-style";
      macos-icon-frame = "aluminum";
      macos-icon-ghost-color = "#cd6600";
      macos-icon-screen-color = "#cd6600";
      macos-option-as-alt = true;
      macos-secure-input-indication = true;
      macos-titlebar-style = "tabs";
      quit-after-last-window-closed = true;
      shell-integration = "detect";
      shell-integration-features = "cursor,sudo,title";
      window-save-state = "always";
      window-theme = "ghostty";
    };
    themes = {
      dracula = {
        background = "#282a36";
        foreground = "#f8f8f2";
        cursor-color = "#f8f8f2";
        cursor-text = "#282a36";
        selection-foreground = "#f8f8f2";
        selection-background = "#44475a";
        palette = [
          " 0=#21222c"
          "1=#ff5555"
          "2=#50fa7"
          "3=#f1fa8c"
          "4=#bd93f9"
          "5=#ff79c6"
          "6=#8be9fd"
          "7=#f8f8f2"
          "8=#6272a4"
          "9=#ff6e6e"
          "10=#69ff94"
          "11=#ffffa5"
          "12=#d6acff"
          "13=#ff92df"
          "14=#a4ffff"
          "15=#ffffff"
        ];
      };
    };
  };
}

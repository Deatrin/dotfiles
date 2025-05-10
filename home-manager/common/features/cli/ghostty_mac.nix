# TODO: This might not be needed once the ghostty package builds sucessfully in nixpkgs
{
  # place ~/$HOME/Library/Application\ Support/com.mitchellh.ghostty/config file
  home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
    clipboard-trim-trailing-spaces = true
    copy-on-select = true

    # use 'fallback' nerdfont symbols font to make default fonts for now because the custom fonts render symbols too small
    # see https://github.com/ghostty-org/ghostty/discussions/3501
    font-family = "Monaspace Neon"
    font-family = "Symbols Nerd Font Mono"

    font-size = 12

    keybind = shift+page_down=scroll_page_down
    keybind = shift+page_up=scroll_page_up
    keybind = super+`=toggle_quick_terminal
    keybind = super+left=previous_tab
    keybind = super+right=next_tab

    macos-auto-secure-input = true
    macos-icon = custom-style
    macos-icon-frame = aluminum
    macos-icon-ghost-color = #cd6600
    macos-icon-screen-color = #cd6600
    macos-option-as-alt = true
    macos-secure-input-indication = true
    macos-titlebar-style = tabs

    quit-after-last-window-closed = true
    shell-integration = "detect"
    shell-integration-features = cursor,sudo,title

    #theme = "catppuccin-mocha"
    theme = "dracula"

    window-height = 35
    window-padding-y = 0
    window-save-state = always
    window-theme = ghostty
    # window-title-font-family = "MonaspiceNe NFM"
    window-width = 280
  '';

  home.file."Library/Application Support/com.mitchellh.ghostty/themes/dracula".text = ''
    palette = 0=#21222c
    palette = 1=#ff5555
    palette = 2=#50fa7b
    palette = 3=#f1fa8c
    palette = 4=#bd93f9
    palette = 5=#ff79c6
    palette = 6=#8be9fd
    palette = 7=#f8f8f2
    palette = 8=#6272a4
    palette = 9=#ff6e6e
    palette = 10=#69ff94
    palette = 11=#ffffa5
    palette = 12=#d6acff
    palette = 13=#ff92df
    palette = 14=#a4ffff
    palette = 15=#ffffff
    background = #282a36
    foreground = #f8f8f2
    cursor-color = #f8f8f2
    cursor-text = #282a36
    selection-foreground = #f8f8f2
    selection-background = #44475a
  '';
}

{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;

    colors = {
      "fg" = "#c0caf5";
      "bg" = "#1a1b26";
      "hl" = "#bb9af7";
      "fg+" = "#c0caf5";
      "bg+" = "#2f3549";
      "hl+" = "#bb9af7";
      "info" = "#0db9d7";
      "prompt" = "#9ece6a";
      "pointer" = "#f7768e";
      "marker" = "#f7768e";
      "spinner" = "#0db9d7";
      "header" = "#444b6a";
    };
    defaultOptions = [
      "--preview='bat --color=always -n {}'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
    defaultCommand = "fd --type f --exclude .git --follow --hidden";
    changeDirWidgetCommand = "fd --type d --exclude .git --follow --hidden";
  };
}

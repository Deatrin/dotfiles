{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.tmux = {
    enable = true;
    package = pkgs.unstable.tmux;
    terminal = "tmux-256color";
    aggressiveResize = true;
    baseIndex = 1;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = false;
    newSession = true;
    shortcut = "a";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      #
      # GENERAL SETTINGS
      #
      set -sa terminal-features ",*256col*:RGB"
      set -s buffer-limit 20
      set -g display-time 1500
      set -g repeat-time 500
      setw -g automatic-rename on
      setw -g automatic-rename-format '#{pane_current_command}'
      setw -g allow-rename off
      setw -g xterm-keys on
      setenv -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
      set -g update-environment -r
      setw -g monitor-activity on
      set -g visual-activity off
      set -g renumber-windows on

      #
      # KEY BINDINGS
      #
      bind-key ^D detach-client
      bind e setw synchronize-panes on
      bind E setw synchronize-panes off
      bind-key -r ^N next-window
      bind-key -r ^P previous-window
      bind-key -r ^D detach-client
      bind-key -n S-Left  previous-window
      bind-key -n S-Right next-window
      bind k confirm-before kill-window
      bind K kill-window
      unbind l
      bind c new-window -c "#{pane_current_path}"
      set -g assume-paste-time 0
      unbind r
      bind r source-file ~/.tmux.conf \; display "Reloaded!"

      #
      # STATUS BAR — Tokyo Night Dark
      #
      set -g status-style "bg=#1a1b26,fg=#c0caf5"
      set -g status-left "#[fg=#bb9af7,bold] #S "
      set -g status-right "#[fg=#565f89] %H:%M "
      set -g status-left-length 20
      set -g status-right-length 20
      set -g status-justify left
      set -g status-interval 2

      set -g window-status-format "#[fg=#565f89] #I #W "
      set -g window-status-current-format "#[fg=#7aa2f7,bold] #I #W "
      set -g window-status-separator ""

      set -g pane-border-style "fg=#3b4261"
      set -g pane-active-border-style "fg=#7aa2f7"
      set -g message-style "bg=#1a1b26,fg=#7aa2f7"

      # Local overrides
      if-shell "[ -f ~/.tmux.conf.user ]" 'source ~/.tmux.conf.user'
    '';
  };
}

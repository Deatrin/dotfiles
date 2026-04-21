{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
    shellAliases = {
      l = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      ltree = "eza --tree --level=2 --icons --git";
      clean = "clear";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "rg";
      ps = "procs";
    };

    initContent = ''
      ZSH_DISABLE_COMPFIX=true
      export EDITOR=nvim
      export PATH=$PATH:$HOME/go/bin
      if [ -n "$TTY" ]; then
        export GPG_TTY=$(tty)
      else
        export GPG_TTY="$TTY"
      fi

      # UWSM auto-start removed - handled by SDDM display manager
      # Hyprland sessions are now launched via SDDM, not shell startup
      # To manually start Hyprland from TTY: uwsm start default

      # Source shell secrets from opnix
      if [ -f "${config.home.homeDirectory}/.config/shell-secrets/env" ]; then
        source ${config.home.homeDirectory}/.config/shell-secrets/env
      fi

      # # SSH_AUTH_SOCK set to GPG to enable using gpgagent as the ssh agent.
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent

      # Empty trigger means plain Tab activates fzf completion (not just **)
      export FZF_COMPLETION_TRIGGER=""

      # Non-recursive completion — only show immediate children
      _fzf_compgen_path() {
        fd --hidden --follow --exclude .git --max-depth 1 . "$1"
      }
      _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude .git --max-depth 1 . "$1"
      }

      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Keybindings
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey '^[w' kill-region

      zle_highlight+=(paste:none)

      setopt appendhistory
      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_save_no_dups
      setopt hist_ignore_dups
      setopt hist_find_no_dups
    '' + lib.optionalString pkgs.stdenv.isDarwin ''
      export PATH="/opt/homebrew/bin:$PATH"
      export PATH="/opt/homebrew/sbin:$PATH"

      eval "$(mise activate zsh)"

      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init - zsh)"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        # "kubectl"
        # "kubectx"
        # "command-not-found"
        # "helm"
      ];
    };
    plugins = [
      {
        # will source zsh-autosuggestions.plugin.zsh
        name = "zsh-autosuggestions";
        src = pkgs.unstable.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.unstable.zsh-completions;
        file = "share/zsh-completions/zsh-completions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.unstable.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
  };
}

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

      if uwsm check may-start && uwsm select; then
        exec uwsm start default
      fi
      source /run/agenix/${config.home.username}-secrets

      export PATH="/opt/homebrew/bin:$PATH"
      export PATH="/opt/homebrew/sbin:$PATH"

      eval "$(mise activate zsh)"

      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init - zsh)"

      # # SSH_AUTH_SOCK set to GPG to enable using gpgagent as the ssh agent.
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent

      bindkey -e

      # disable sort when completing `git checkout`
      zstyle ':completion:*:git-checkout:*' sort false

      # set descriptions format to enable group support
      # NOTE: don't use escape sequences here, fzf-tab will ignore them
      zstyle ':completion:*:descriptions' format '[%d]'

      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
      zstyle ':completion:*' menu no

      # preview directory's content with eza when completing cd
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:ls:*' fzf-preview 'cat $realpath'

      # switch group using `<` and `>`
      zstyle ':fzf-tab:*' switch-group '<' '>'

      # Keybindings
      bindkey -e
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
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
  };
}

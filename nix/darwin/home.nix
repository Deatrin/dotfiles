{ 
    config,
    pkgs, 
    ...
}: let
        inherit (config.lib.file) mkOutOfStoreSymlink;

    in {
        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
        # Home Manager needs a bit of information about you and the
        # paths it should manage.
        home.username = "ajennex";
        home.homeDirectory = "/Users/ajennex";
        xdg.enable = true;

        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        home.stateVersion = "24.05";
        programs = {
            # fzf = import ../home/fzf.nix {inherit pkgs;};
            git = import ../home/git.nix { inherit config pkgs; };
            oh-my-posh = import ../home/oh-my-posh.nix {inherit pkgs;};
            tmux = import ../home/tmux.nix {inherit pkgs;};
            zsh = import ../home/zsh.nix {inherit config pkgs;};
        };

    }
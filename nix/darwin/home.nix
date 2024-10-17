{ 
  config,
  pkgs,
  lib, 
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

  xdg.configFile.nvim.source = mkOutOfStoreSymlink "/Users/ajennex/Development/dotfiles/.config/nvim";

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
    alacritty = import ../home/alacritty.nix {inherit pkgs;};
    fzf = import ../home/fzf.nix {inherit pkgs;};
    git = import ../home/git.nix { inherit config pkgs; };
    oh-my-posh = import ../home/oh-my-posh.nix {inherit pkgs;};
    neovim = import ../home/neovim.nix {inherit config pkgs;};
    tmux = import ../home/tmux.nix {inherit pkgs;};
    zsh = import ../home/zsh.nix {inherit config pkgs lib;};
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
};
}

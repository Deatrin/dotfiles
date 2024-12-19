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
  home.file.".gnupg/gpg-agent.conf".source = config.lib.file.mkOutOfStoreSymlink "/Users/ajennex/Development/dotfiles/.config/gpg-agent/gpg-agent.conf";

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
    alacritty = import ../home/darwin/alacritty.nix {inherit pkgs;};
    fzf = import ../home/darwin/fzf.nix {inherit pkgs;};
    git = import ../home/darwin/git.nix {inherit config pkgs;};
    gpg = import ../home/darwin/gpg.nix {inherit pkgs;};
    oh-my-posh = import ../home/darwin/oh-my-posh.nix {inherit pkgs;};
    neovim = import ../home/darwin/neovim.nix {inherit config pkgs;};
    tmux = import ../home/darwin/tmux.nix {inherit pkgs;};
    zoxide = import ../home/darwin/zoxide.nix {inherit config pkgs;};
    zsh = import ../home/darwin/zsh.nix {inherit config pkgs lib;};
  };
}

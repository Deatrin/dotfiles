{
  config,
  pkgs,
  ...
}: {
  # enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "/home/deatrin/development/dotfiles/.config/nvim";
}

{...}: {
  enable = true;
  enableZshIntegration = true;
  settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../../.config/ohmyposh/amro.toml));
}

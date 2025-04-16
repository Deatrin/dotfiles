{pkgs, ...}: {
  imports = [
    ./bat.nix
    ./fzf.nix
    ./fonts.nix
    ./git.nix
    ./gpg.nix
    ./zsh.nix
  ];
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraOptions = ["-l" "--icons" "--git" "-a"];
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.unsafeDiscardStringContext (builtins.readFile ../../../../.config/ohmyposh/amro.toml));
  };

  programs.bat = {enable = true;};

  home.packages = with pkgs; [
    coreutils
    fastfetch
    fd
    htop
    httpie
    jq
    packer
    procs
    ripgrep
    tenv
    tldr
    zig
    zip
  ];
}

{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports =
    [
      inputs.nix-colors.homeManagerModules.default
      inputs.opnix.homeManagerModules.default
      inputs.nvf.homeManagerModules.default
      ../features/cli
    ]
    ++ (builtins.attrValues outputs.homeManagerModules)
    ++ (builtins.attrValues (outputs.modules.homeManager or {}));

  # No nixpkgs block: every host sets home-manager.useGlobalPkgs, so pkgs
  # (overlays + config) comes from the host's own nixpkgs settings.

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  colorscheme = lib.mkDefault (import ../../../modules/home-manager/colorschemes/tokyo-night.nix);
  home.file.".colorscheme".text = config.colorscheme.slug;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    OLLAMA_HOST = "https://ollama.jennex.dev";
  };
}

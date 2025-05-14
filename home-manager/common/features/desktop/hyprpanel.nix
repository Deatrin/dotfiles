{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.hyprpanel.homeManagerModules.hyprpanel];
  home.packages = with pkgs; [
    hyprpanel
  ];
  programs.hyprpanel = {
    # Enable the module.
    # Default: false
    enable = true;
    overlay.enable = true;

    settings = {
      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;
      theme.font = {
        name = "jetbrains-mono";
      };
    };
    # Fix the overwrite issue with HyprPanel.
    # See below for more information.
    # Default: false
    overwrite.enable = true;
  };
}

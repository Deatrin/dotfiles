{ config, ... }: { 
    imports = [ 
      ./home.nix
      ./dotfiles
      ../common
      ../features/cli
      ../features/desktop
    ];
    
    features = {
      cli = {
        zsh.enable = true;
        fzf.enable = true;
        neofetch.enable = true;
        tmux.enable = true;
      };
      desktop = {
        wayland.enable = true;
        hyprland.enable = true;
        fonts.enable = true;
      };
    };
  
    wayland.windowManager.hyprland = {
      settings = {
        device = [
          {
            name = "keyboard";
            kb_layout = "us";
          }
          {
            name = "mouse";
            sensitivity = -0.5;
          }
        ];
        monitor = [
          "eDP-1,1920x1200@60,0x0,1"
        ];
        workspace = [
          "1, monitor:eDP-1, default:true"
          "2, monitor:DP-1"
          "3, monitor:DP-1"
          "4, monitor:DP-2"
          "5, monitor:DP-1"
          "6, monitor:DP-2"
          "7, monitor:DP-2"
        ];
      };
    };
  }

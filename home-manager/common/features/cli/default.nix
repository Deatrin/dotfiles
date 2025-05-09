{pkgs, ...}: {
  imports = [
    # ./atuin.nix
    ./bat.nix
    ./direnv.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./nvf.nix
    ./opnix.nix
    ./tealdeer.nix
    ./tmux.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    # _1password # password manager CLI - installing this break op CLI on macbooks
    # age # encryption tool
    any-nix-shell # supports any shell in nix-shell (https://github.com/haslersn/any-nix-shell)
    bottom # better top "WRITTEN IN RUST"
    btop
    # curl # get things from URLs
    dig # DNS lookups
    dogdns # DNS lookups "WRITTEN IN RUST"
    duf # better 'df' "WRITTEN IN RUST"
    unstable.eza # replacement for exa "WRITTEN IN RUST"
    unstable.fastfetch # fetch system info
    fd # better find "WRITTEN IN RUST""
    file # inspect file types
    git-crypt # encrypt files in git
    htop # system monitor
    hyperfine # benchmarking tool "WRITTEN IN RUST"
    ipcalc # calculate IP ranges
    ipinfo # get IP info
    jq # JSON pretty printer and manipulator
    jwt-cli # JWT tool
    lazygit
    nixd # nix daemon
    nixfmt-rfc-style # nix formatter
    nvd # nix version diff
    ouch # better unzip "WRITTEN IN RUST"
    procs # better ps "WRITTEN IN RUST"
    ripgrep # Better grep "WRITTEN IN RUST"
    sd # better sed "WRITTEN IN RUST"
    wget # get things from URLs
    yq # YAML pretty printer and manipulator
  ];
}

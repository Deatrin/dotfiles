{ config, pkgs, ... }: {
  let
    gpgConfig = pkgs.writeText "gpg-agent.conf" ''
    enable-ssh-support
    ttyname $GPG_TTY
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program /run/current-system/sw/bin/pinentry-mac
    '';
  in {
    home.file.".gnupg/gpg-agent.conf".source = gpgConfig
  };
}
{ pkgs, ... }: {
  enable = true;
  enableZshIntegration = true;

  defaultCacheTtlSsh = 60;
  enableSshSupport = true;
  maxCacheTtl = 120;
  

  
  extraConfig = ''
  pinentry-program /run/current-system/sw/bin/pinentry-mac

  ttyname $GPG_TTY
  ''

}
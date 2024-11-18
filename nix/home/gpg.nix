{pkgs, ...}: {
  enable = true;

  publicKeys = [
    {source = ../../keys/AA7FEB9A60111FBC-2024-10-18.asc;}
  ];
}

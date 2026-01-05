{pkgs, ...}: {
  environment.systemPackages = with pkgs.unstable; [
    moonlight-qt
  ];
}

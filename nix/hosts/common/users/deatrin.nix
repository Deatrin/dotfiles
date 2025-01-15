{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.deatrin = {
    initialHashedPassword = "$y$j9T$ubrmfsxzOK4EuYl7KTdp81$ac./pAT.2yhEIrLNU.FNzlNeRdxX8DPPcyvCGHtooaC";
    isNormalUser = true;
    description = "Deatrin";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6Dj0qtyqBdKHI5JEX+DtJBoVicCRJ3f1N1CnhyKuQCfNHY7mTxl8PyklRnzGsb9YtnXYbfUJdsDj42NXczFzS+3vO5OzIS7t7FMfWjutSdNCXCVsuMRB8NpbUcLzAj4WQTm5WyvyRO3ksvDH2Yd6+sPH46ccl18SWquXD4i3cI2N2yadRPbQO1WEoQzQAcTBjhaI+phBIwYvdutM+rvoQ19Q0IzKImbFe1gqNv87hvIc+Vjk+FVLxv5qMFCg/8ivn8o8dYRl0vpxWTy+9Dohk7a2tXTBpoV1POVQMHrm1sYj4j5OdoqkHeUJXi8Yjc3ytYYcFDrux9fUZIX46BhbkMQyQHhFC5Nz61rEWVFzScHc2LHPHWoD3Uhsq1m8ciKBvaIi5GCaScIl2SSO0rt7NZ2+tbpF1yryC4gTAw1zxDxcZYMNMHTyRtXi1WBrip4weq5cG693vJ0cy6HYESqtG2O5tDUhtyWMtrTgkV0SP4JpEBJjdFvzJoJcigmWsmHejx+VxKBK+63xqNlxkA52sW/n7bwlg0g7fItKyjzjWvx2XH1CzfymaV3Mz3ifqyx2dKHOEmDptLLvTnhPnW+IfWZNoEVF/phqQc9fbUFvsTvBdOq2NfujjnzlZs0gtVgozv3/9bkJKo+xbO5JJXqXb0fUPyeA6WtKetvPtzNLdVw== cardno:28_605_076"
    ]; # to add more keys just and a new line and put it in quotes
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.deatrin =
    import deatrin/${config.networking.hostName}.nix;
}

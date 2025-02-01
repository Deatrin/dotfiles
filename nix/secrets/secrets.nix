let
  # Systems
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7TK5R4ssKW9wKCqxh4h4FSfZEUuHC9Ym8PoRBQcun4";
  # tachi = "";
  # tycho = "";

  # Users
  deatrin = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6Dj0qtyqBdKHI5JEX+DtJBoVicCRJ3f1N1CnhyKuQCfNHY7mTxl8PyklRnzGsb9YtnXYbfUJdsDj42NXczFzS+3vO5OzIS7t7FMfWjutSdNCXCVsuMRB8NpbUcLzAj4WQTm5WyvyRO3ksvDH2Yd6+sPH46ccl18SWquXD4i3cI2N2yadRPbQO1WEoQzQAcTBjhaI+phBIwYvdutM+rvoQ19Q0IzKImbFe1gqNv87hvIc+Vjk+FVLxv5qMFCg/8ivn8o8dYRl0vpxWTy+9Dohk7a2tXTBpoV1POVQMHrm1sYj4j5OdoqkHeUJXi8Yjc3ytYYcFDrux9fUZIX46BhbkMQyQHhFC5Nz61rEWVFzScHc2LHPHWoD3Uhsq1m8ciKBvaIi5GCaScIl2SSO0rt7NZ2+tbpF1yryC4gTAw1zxDxcZYMNMHTyRtXi1WBrip4weq5cG693vJ0cy6HYESqtG2O5tDUhtyWMtrTgkV0SP4JpEBJjdFvzJoJcigmWsmHejx+VxKBK+63xqNlxkA52sW/n7bwlg0g7fItKyjzjWvx2XH1CzfymaV3Mz3ifqyx2dKHOEmDptLLvTnhPnW+IfWZNoEVF/phqQc9fbUFvsTvBdOq2NfujjnzlZs0gtVgozv3/9bkJKo+xbO5JJXqXb0fUPyeA6WtKetvPtzNLdVw== openpgp:0xD694D851";
in {
  "secret1.age".publicKeys = [razerback];
  "deatrin-secrets.age".publicKeys = [razerback deatrin];
}

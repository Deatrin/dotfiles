let
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7TK5R4ssKW9wKCqxh4h4FSfZEUuHC9Ym8PoRBQcun4";
  # tachi = "";
  # tycho = "";
in {
  "secret1.age".publicKeys = [razerback];
}

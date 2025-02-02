let
  # Systems
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7TK5R4ssKW9wKCqxh4h4FSfZEUuHC9Ym8PoRBQcun4";
  # tachi = "";
  tachivirt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZMh5dPobv5smtZTf8677VupkqdXG86tYiS7KWDa47v";
  tycho = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdtJIDcBIYAYkHxvIGF3Sg9avlSjZNU5TKmOZacK4Vk";

  # Users
  deatrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzIb3yvc65BxpM2hjwNhs9viZdYTRm+FCBOLcoVwOzf";
in {
  "secret1.age".publicKeys = [razerback tycho tachivirt deatrin];
  "deatrin-secrets.age".publicKeys = [razerback tycho tachvirt deatrin];
}

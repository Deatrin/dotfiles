let
  # Systems
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7TK5R4ssKW9wKCqxh4h4FSfZEUuHC9Ym8PoRBQcun4";
  # tachi = "";
  tachivirt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT5MjnlrTk7bdCBlZdH205XfDyqsT0g9b8I+lyTZd3H";
  tycho = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdtJIDcBIYAYkHxvIGF3Sg9avlSjZNU5TKmOZacK4Vk";

  # Users
  deatrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzIb3yvc65BxpM2hjwNhs9viZdYTRm+FCBOLcoVwOzf";

  users = [
    deatrin
  ];

  systems = [
    razerback
    # tachi
    tachivirt
    tycho
  ];
in {
  "secret1.age".publicKeys = systems ++ users;
  "deatrin-secrets.age".publicKeys = systems ++ users;
}

let
  # Systems
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK86jag7YpxLKMDY+KSrtOP2U9cKiXVFBq2QNC0AhNeC";
  tachi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKibh5GTexyqYUlCN5jfhLxxM9AE8irXmkjh+fsbuGTo";
  nauvoo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3ah6CaGRPAYgDjf0o02gqhLuNPidFRcYwVNjxeMaiW";
  tycho = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPz3wiePro7pwMuqK2Dbxfa6F4uQN+6HDSDCIVOWowYI";

  # Users
  deatrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzIb3yvc65BxpM2hjwNhs9viZdYTRm+FCBOLcoVwOzf";

  users = [
    deatrin
  ];

  systems = [
    razerback
    tachi
    nauvoo
    tycho
  ];
in {
  "deatrin-secrets.age".publicKeys = systems ++ users;
  "cloudflareddns.age".publicKeys = systems ++ users;
  "cloudflaretunnel.age".publicKeys = systems ++ users;
  "homepage.age".publicKeys = systems ++ users;
  "idrac.age".publicKeys = systems ++ users;
  "immich.age".publicKeys = systems ++ users;
  "mealie.age".publicKeys = systems ++ users;
  "minio.age".publicKeys = systems ++ users;
  "monitoring.age".publicKeys = systems ++ users;
  "n8n.age".publicKeys = systems ++ users;
  "paperless.age".publicKeys = systems ++ users;
  "renovate.age".publicKeys = systems ++ users;
  "tailscale-key.age".publicKeys = systems ++ users;
  "traefik.age".publicKeys = systems ++ users;
}

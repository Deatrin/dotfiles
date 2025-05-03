let
  # Systems
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZwU7D1AaKmtxj70Ujautj6xJEME0ldrmi0tBc9LNtI";
  tachi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKibh5GTexyqYUlCN5jfhLxxM9AE8irXmkjh+fsbuGTo";
  nauvoo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5lpFFv1P0wcit8dYSN723Um30CUudt6gEykVR/twbB";
  tycho = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc39gdL4PClqHy8iOajHQWoy15mKujglhWmGMXHNld7";

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
  "secret1.age".publicKeys = systems ++ users;
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

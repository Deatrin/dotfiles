let
  razerback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtfGo0zja7m0xzFgW7Bd7TwcfGmZWrN5HvcUl3F+SJx";
  deatrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY06wy+S3ze6CsUzIPQmErBxT4V3FLfAIzANNDEogte jennexa@gmail.com";
in {
  "deatrin-secrets.age".publicKeys = [razerback deatrin];
}
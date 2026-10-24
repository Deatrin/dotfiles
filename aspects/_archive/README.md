# Archived aspects

import-tree skips any path containing `/_`, so nothing here is loaded.
To bring an aspect back, move it to `aspects/<class>/`.

- `nixos/qemu.nix` — QEMU guest agent (`services.qemuGuest`); enabled nowhere. Useful again if a host runs as a VM.
- `homeManager/opnix-servers.nix` — Server-vault opnix user secrets; secrets list was empty and it was enabled nowhere.

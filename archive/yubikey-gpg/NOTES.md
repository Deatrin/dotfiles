# YubiKey → 1Password migration — archived files & handoff notes

Written 2026-07-31. Picking this up on a different machine? Read this first.

## Why

Dropped the YubiKey (GPG OpenPGP applet for signing/SSH-auth, plus `pam_u2f`
FIDO2/U2F applet for sudo MFA) — clunky to carry, and the pocketable "nano"
form factor wasn't worth the cost. Replaced with the **1Password SSH agent**:
one SSH key generated in the 1Password vault, used for both SSH auth and
SSH-format git/jj commit signing, syncing across hosts automatically instead
of needing a physical token.

Full original plan (context, all options considered, rationale) is at
`~/.claude/plans/agile-soaring-brooks.md` on the machine this was written on
— may not be present on a new machine, but this file plus the git diff should
be enough to pick the work back up.

## What's archived here

- **`gpg.nix`** — was `home-manager/common/features/cli/gpg.nix`. Configured
  `programs.gpg` + `services.gpg-agent` (with `enableSshSupport`) against the
  YubiKey's OpenPGP applet. No longer imported anywhere (removed from
  `home-manager/common/features/cli/default.nix`) — kept here in case the
  1Password approach needs to be rolled back.
- **`AA7FEB9A60111FBC-2024-10-18.asc`** — the old GPG public key, was at
  `keys/AA7FEB9A60111FBC-2024-10-18.asc`, only ever referenced by `gpg.nix`.

Both are inert — moving them here didn't require touching anything else,
since `gpg.nix` was already unimported before this move. Nothing in the repo
references this `archive/yubikey-gpg/` directory.

**To roll back**: `git mv` these two files back to their original paths, restore the removed lines in `git.nix`/`jj.nix`/`zsh.nix`/`hosts/common/nixos/default.nix` (see git log/diff for the commit that made these changes), and re-add `./gpg.nix` to `home-manager/common/features/cli/default.nix`'s imports.

## New signing key

The 1Password-generated SSH public key now used everywhere for signing + auth:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdV7xPZWsMYD/bPGyrN+o+/5Fs72LmezBHnkenkYD5i
```
It's hardcoded (public keys aren't secret) into `git.nix` and `jj.nix`.

## Code changes made (all already committed to the working tree, not yet all rolled out)

- `home-manager/common/features/cli/default.nix` — removed `./gpg.nix` import.
- `home-manager/common/features/cli/git.nix` — GPG signing → `gpg.format = "ssh"`, `signer` = platform-conditional path to `op-ssh-sign` (Darwin: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`; Linux: `${pkgs._1password-gui}/bin/op-ssh-sign`, confirmed against the pinned nixpkgs derivation). Also folded a pre-existing duplicate `settings = {}` block into one.
- `home-manager/common/features/cli/jj.nix` — `signing.backend` gpg → ssh, `signing.backends.ssh.program` = same op-ssh-sign path.
- `home-manager/common/features/cli/zsh.nix` — `SSH_AUTH_SOCK` now points at 1Password's agent socket (checks macOS path, falls back to Linux path, left unset if neither socket exists — e.g. on headless `nauvoo`).
- `home-manager/common/features/cli/tmux.nix` — removed a **pre-existing bug**: a stale `setenv -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock` line that pointed at a path nothing ever created, breaking SSH auth inside every tmux session on every host. Fixed as part of this migration since the new setup needed it working.
- `hosts/common/nixos/default.nix` — removed `pam_u2f` sudo MFA, `pcscd`, `yubikey-agent` (confirmed already dead/unused — nothing ever pointed `SSH_AUTH_SOCK` at its socket), and the `yubikey-personalization` udev rule. Kept `programs.ssh.startAgent = false` (still correct — want 1Password's agent as the sole SSH agent).
- `home-manager/nixos/deatrin_tycho.nix` — removed `yubioath-flutter`/`yubikey-manager` packages.

## Manual steps done / needed per host

1. Generated a new SSH key in the 1Password app (done — see key above).
2. Enable **1Password → Settings → Developer → "Use the SSH agent"** on each
   interactive host before switching it (not needed on headless `nauvoo`).
3. New key already trusted by Forgejo (`forgejo.jennex.dev`) — SSH auth
   confirmed working there during scirocco verification.
4. Old GPG key is still fine to leave registered wherever it's trusted for
   now — **do not revoke/remove it from Forgejo/GitHub yet**, not all hosts
   are migrated.

## Rollout status (as of 2026-07-31)

- **scirocco** (Darwin, pilot) — fully switched & verified: 1Password agent
  socket live, SSH auth to Forgejo works, git commit signing verified
  ("Good git signature"), jj commit signing verified (`signed:yes`), and
  re-verified working inside a fresh tmux session (confirms the tmux fix).
- **artemis** (NixOS, pilot for the `pam_u2f` removal) — switched by the user,
  confirmed good.
- **nauvoo** — NOT YET switched. Just needs `sudo nixos-rebuild switch
  --flake .#nauvoo` (no 1Password agent toggle needed, it's headless — its
  Forgejo CI already signs with its own separate key, see
  `.forgejo/workflows/flake-bump.yml`, untouched by this migration).
- **donnager** — NOT YET switched. Needs the 1Password agent toggle enabled
  first (see Manual step 2), then `darwin-rebuild switch --flake .#donnager`.
- **tynan** — NOT YET switched. Same as donnager:
  `darwin-rebuild switch --flake .#tynan` after enabling the agent toggle.

**Note on workflow**: the user runs all `switch`/`rebuild` commands
themselves — don't run these, just hand over the exact command.

## Left to do after all hosts are switched and verified

1. Delete this whole `archive/yubikey-gpg/` directory (or keep it longer if
   you want a bigger safety margin — your call).
2. Remove the old GPG key from Forgejo/GitHub's registered keys.
3. Clean up the leftover YubiKey mentions in `hosts/nixos/tycho/README.md`
   (table entry, package list, "YubiKey GPG issues" troubleshooting section).
4. Optional: set up `gpg.ssh.allowedSignersFile` for local
   `git log --show-signature` verification — not required, Forgejo/GitHub
   verify server-side against the uploaded pubkey regardless. Came up during
   scirocco verification as a "nice to have, not a blocker."

# Secrets Management

This repository uses **opnix** for secrets management via 1Password integration.

## Migration Notice

This directory contains archived agenix (age-encrypted) secrets from before the opnix migration (December 2024). These files are preserved for reference but are no longer used.

## Current Secrets Management: Opnix

Secrets are now managed through opnix (1Password service accounts):

- **System-level secrets**: Configured per-host in `hosts/<platform>/<hostname>/secrets.nix`
- **User-level secrets**: Configured in `home-manager/common/features/cli/opnix_personal.nix` and `opnix_servers.nix`

### Setup

1. Create a 1Password service account with read access to relevant vaults
2. Set the token on each host:
   ```bash
   sudo opnix token set
   ```
3. Configure secrets in the appropriate config files
4. Rebuild system - secrets are provisioned automatically

### Documentation

For comprehensive opnix documentation including:
- Configuration examples
- Secret naming requirements (camelCase)
- System vs user-level secrets
- Per-host setup instructions

See the **Secrets Management (opnix)** section in [CLAUDE.md](../CLAUDE.md).

## Archive Contents

The agenix files in this directory are preserved but unused:
- *.age files: Encrypted secrets
- secrets.nix: Secret mappings (deprecated)
- See `backup/agenix-migration-2024-12/README.md` for migration details

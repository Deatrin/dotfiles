# op-connect-secrets — fetch secrets from a local 1Password Connect server
#
# Drop-in replacement for opnix on hosts running a local Connect server.
# Writes secrets to the same /run/opnix/ paths so all existing container
# modules require zero changes.
#
# Prerequisites (manually placed before first rebuild):
#   /etc/op-connect/1password-credentials.json  — from 1Password developer portal
#   /etc/op-connect-token                       — Connect access token
#
# Bootstrap:
#   1. 1Password.com → Developer Tools → Connect Servers → create server
#   2. Download 1password-credentials.json, generate access token
#   3. sudo mkdir -p /etc/op-connect && sudo chmod 700 /etc/op-connect
#   4. sudo cp 1password-credentials.json /etc/op-connect/ && sudo chmod 600 /etc/op-connect/1password-credentials.json
#   5. echo -n "token" | sudo tee /etc/op-connect-token && sudo chmod 600 /etc/op-connect-token
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.op-connect-secrets;

  secretType = lib.types.submodule {
    options = {
      reference = lib.mkOption {
        type = lib.types.str;
        description = "1Password reference: op://vault/item/field";
      };
      path = lib.mkOption {
        type = lib.types.str;
        description = "Absolute destination path for the secret file";
      };
      owner = lib.mkOption {
        type = lib.types.str;
        default = "root";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "root";
      };
      mode = lib.mkOption {
        type = lib.types.str;
        default = "0600";
      };
    };
  };

  fetchScript = pkgs.writeShellApplication {
    name = "op-connect-secrets-fetch";
    runtimeInputs = [pkgs._1password pkgs.curl pkgs.coreutils];
    text = ''
      # Wait for Connect API to be healthy
      MAX_WAIT=120
      count=0
      until curl -sf "${cfg.connectHost}/health" > /dev/null 2>&1; do
        if [ "$count" -ge "$MAX_WAIT" ]; then
          echo "ERROR: 1Password Connect API not ready after ''${MAX_WAIT}s"
          exit 1
        fi
        echo "Waiting for Connect API... (''${count}s)"
        sleep 1
        count=$((count + 1))
      done
      echo "Connect API is healthy"

      OP_CONNECT_TOKEN=$(cat "${cfg.tokenFile}")
      export OP_CONNECT_TOKEN
      export OP_CONNECT_HOST="${cfg.connectHost}"

      ${lib.concatMapStrings (s: ''
        echo "Fetching: ${s.value.reference} -> ${s.value.path}"
        mkdir -p "$(dirname "${s.value.path}")"
        op read "${s.value.reference}" --out-file "${s.value.path}"
        chown "${s.value.owner}:${s.value.group}" "${s.value.path}"
        chmod "${s.value.mode}" "${s.value.path}"
      '') (lib.attrsToList cfg.secrets)}

      echo "All secrets provisioned"
    '';
  };
in {
  options.services.op-connect-secrets = {
    enable = lib.mkEnableOption "1Password Connect secrets provisioning";

    connectHost = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8080";
      description = "URL of the local 1Password Connect API server";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/op-connect-token";
      description = "Path to file containing the Connect access token";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users to add to the op-connect-secrets group";
    };

    secrets = lib.mkOption {
      type = lib.types.attrsOf secretType;
      default = {};
      description = "Secret definitions";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.op-connect-secrets = {};
    users.users = lib.genAttrs cfg.users (_: {
      extraGroups = ["op-connect-secrets"];
    });

    systemd.services.op-connect-secrets = {
      description = "Provision secrets from 1Password Connect";
      after = ["network-online.target" "op-connect-api.service"];
      requires = ["op-connect-api.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "180";
        ExecStart = lib.getExe fetchScript;
      };
    };

    # Compatibility shim — all existing container modules use
    # after/requires = ["opnix-secrets.service"] and require zero changes
    systemd.services.opnix-secrets = {
      description = "opnix-secrets compatibility shim (delegates to op-connect-secrets)";
      after = ["op-connect-secrets.service"];
      requires = ["op-connect-secrets.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/true";
      };
    };
  };
}

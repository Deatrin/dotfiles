# iDRAC Fan Controller — Dell server fan speed management
#
# Controls fan speeds on two Dell servers via iDRAC.
# No web UI — no Traefik labels needed.
#
# Secrets required (op://nix_secrets/idrac/):
#   IDRAC_HOST_1, IDRAC_HOST_2, IDRAC_USERNAME, IDRAC_PASSWORD
#
# Nauvoo-specific: iDRAC hosts are only reachable from the homelab network.
{...}: {
  systemd.services.idrac-env-setup = {
    description = "Build iDRAC fan controller env files from opnix secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["idrac-controller-1.service" "idrac-controller-2.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      HOST_1=$(cat /run/opnix/idrac-host-1)
      HOST_2=$(cat /run/opnix/idrac-host-2)
      USERNAME=$(cat /run/opnix/idrac-username)
      PASSWORD=$(cat /run/opnix/idrac-password)

      mkdir -p /run/idrac
      printf 'IDRAC_HOST=%s\nIDRAC_USERNAME=%s\nIDRAC_PASSWORD=%s\n' \
        "$HOST_1" "$USERNAME" "$PASSWORD" > /run/idrac/controller-1.env
      printf 'IDRAC_HOST=%s\nIDRAC_USERNAME=%s\nIDRAC_PASSWORD=%s\n' \
        "$HOST_2" "$USERNAME" "$PASSWORD" > /run/idrac/controller-2.env
      chmod 600 /run/idrac/controller-1.env /run/idrac/controller-2.env
    '';
  };

  virtualisation.quadlet = {
    containers."idrac-controller-1" = {
      unitConfig = {
        After = ["idrac-env-setup.service"];
        Requires = ["idrac-env-setup.service"];
      };
      containerConfig = {
        image = "tigerblue77/dell_idrac_fan_controller:latest";
        autoUpdate = "registry";
        environmentFiles = ["/run/idrac/controller-1.env"];
        environments = {
          FAN_SPEED = "50";
          CPU_TEMPERATURE_THRESHOLD = "70";
          CHECK_INTERVAL = "60";
          DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE = "true";
        };
      };
    };

    containers."idrac-controller-2" = {
      unitConfig = {
        After = ["idrac-env-setup.service"];
        Requires = ["idrac-env-setup.service"];
      };
      containerConfig = {
        image = "tigerblue77/dell_idrac_fan_controller:latest";
        autoUpdate = "registry";
        environmentFiles = ["/run/idrac/controller-2.env"];
        environments = {
          FAN_SPEED = "50";
          CPU_TEMPERATURE_THRESHOLD = "70";
          CHECK_INTERVAL = "60";
          DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE = "true";
        };
      };
    };
  };
}

# Monitoring stack — Prometheus + Grafana + Loki + Promtail + UnPoller
#
# Secrets required (via opnix):
#   /run/opnix/monitoring-unpoller-username      — UniFi read-only account username
#   /run/opnix/monitoring-unpoller-password      — UniFi read-only account password
#   /run/opnix/monitoring-grafana-admin-password — Grafana admin password
#
# Pre-requisites:
#   - Read-only local account on UniFi controller (username: unpoller)
#   - traefik-forward-auth container deployed (provides forward-auth middleware)
#
# Routing (via Traefik):
#   grafana.jennex.dev → monitoring-grafana:3000 (behind Pocket ID forward auth)
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;

  prometheusConfig = pkgs.writeText "prometheus.yml" ''
    global:
      scrape_interval: 30s
      evaluation_interval: 30s

    scrape_configs:
      - job_name: unifipoller
        static_configs:
          - targets: ['monitoring-unpoller:9130']
  '';

  lokiConfig = pkgs.writeText "loki-config.yaml" ''
    auth_enabled: false

    server:
      http_listen_port: 3100

    common:
      instance_addr: 127.0.0.1
      path_prefix: /loki
      storage:
        filesystem:
          chunks_directory: /loki/chunks
          rules_directory: /loki/rules
      replication_factor: 1
      ring:
        kvstore:
          store: inmemory

    schema_config:
      configs:
        - from: 2020-10-24
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h

    limits_config:
      reject_old_samples: true
      reject_old_samples_max_age: 168h
  '';

  promtailConfig = pkgs.writeText "promtail-config.yaml" ''
    server:
      http_listen_port: 9080
      grpc_listen_port: 0

    positions:
      filename: /tmp/positions.yaml

    clients:
      - url: http://monitoring-loki:3100/loki/api/v1/push

    scrape_configs:
      - job_name: journal
        journal:
          max_age: 12h
          labels:
            job: systemd-journal
            host: nauvoo
        relabel_configs:
          - source_labels: ['__journal__systemd_unit']
            target_label: unit
          - source_labels: ['__journal__hostname']
            target_label: hostname
          - source_labels: ['__journal__container_name']
            target_label: container
          - source_labels: ['__journal__image_name']
            target_label: image
  '';

  grafanaDatasources = pkgs.writeText "datasources.yaml" ''
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        uid: prometheus
        url: http://monitoring-prometheus:9090
        isDefault: true
        editable: false
        version: 1
      - name: Loki
        type: loki
        access: proxy
        uid: loki
        url: http://monitoring-loki:3100
        editable: false
        version: 1
  '';
in {
  systemd.services.monitoring-env-setup = {
    description = "Build monitoring environment files from secrets";
    after = ["opnix-secrets.service"];
    requires = ["opnix-secrets.service"];
    before = ["monitoring-unpoller.service" "monitoring-grafana.service"];
    wantedBy = ["monitoring-unpoller.service" "monitoring-grafana.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "monitoring-env-setup";
        text = ''
          {
            printf 'UP_UNIFI_CONTROLLER_0_USER=%s\n' "$(cat /run/opnix/monitoring-unpoller-username)"
            printf 'UP_UNIFI_CONTROLLER_0_PASS=%s\n' "$(cat /run/opnix/monitoring-unpoller-password)"
          } > /run/opnix/monitoring-unpoller-env
          chmod 600 /run/opnix/monitoring-unpoller-env

          {
            printf 'GF_SECURITY_ADMIN_PASSWORD=%s\n' "$(cat /run/opnix/monitoring-grafana-admin-password)"
          } > /run/opnix/monitoring-grafana-env
          chmod 600 /run/opnix/monitoring-grafana-env
        '';
      });
    };
  };

  virtualisation.quadlet = {
    networks.monitoring_network = {};

    volumes = {
      monitoring-prometheus = {};
      monitoring-grafana = {};
      monitoring-loki = {};
    };

    containers.monitoring-prometheus = {
      containerConfig = {
        image = "docker.io/prom/prometheus:latest";
        autoUpdate = "registry";
        networks = [networks.monitoring_network.ref];
        exec = "--config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --storage.tsdb.retention.time=30d --storage.tsdb.wal-compression --web.enable-lifecycle";
        volumes = [
          "${prometheusConfig}:/etc/prometheus/prometheus.yml:ro"
          "${volumes.monitoring-prometheus.ref}:/prometheus"
        ];
      };
    };

    containers.monitoring-loki = {
      containerConfig = {
        image = "docker.io/grafana/loki:latest";
        autoUpdate = "registry";
        networks = [networks.monitoring_network.ref];
        volumes = [
          "${lokiConfig}:/etc/loki/local-config.yaml:ro"
          "${volumes.monitoring-loki.ref}:/loki"
        ];
      };
    };

    containers.monitoring-promtail = {
      unitConfig = {
        After = ["monitoring-loki.service"];
        Requires = ["monitoring-loki.service"];
      };
      containerConfig = {
        image = "docker.io/grafana/promtail:latest";
        autoUpdate = "registry";
        networks = [networks.monitoring_network.ref];
        volumes = [
          "${promtailConfig}:/etc/promtail/config.yml:ro"
          "/var/log/journal:/var/log/journal:ro"
          "/run/log/journal:/run/log/journal:ro"
          "/etc/machine-id:/etc/machine-id:ro"
        ];
      };
    };

    containers.monitoring-unpoller = {
      unitConfig = {
        After = ["opnix-secrets.service" "monitoring-env-setup.service"];
        Requires = ["opnix-secrets.service" "monitoring-env-setup.service"];
      };
      containerConfig = {
        image = "ghcr.io/unpoller/unpoller:latest";
        autoUpdate = "registry";
        networks = [networks.monitoring_network.ref];
        environments = {
          UP_UNIFI_CONTROLLER_0_URL = "https://10.1.1.1";
          UP_UNIFI_CONTROLLER_0_SITE = "default";
          UP_UNIFI_CONTROLLER_0_VERIFY_SSL = "false";
          UP_UNIFI_CONTROLLER_0_SAVE_SITES = "true";
          UP_UNIFI_CONTROLLER_0_SAVE_IDS = "false";
          UP_UNIFI_CONTROLLER_0_SAVE_EVENTS = "true";
          UP_UNIFI_CONTROLLER_0_SAVE_ALARMS = "true";
          UP_UNIFI_CONTROLLER_0_SAVE_ANOMALIES = "true";
          UP_UNIFI_CONTROLLER_0_SAVE_DPI = "true";
          UP_INFLUXDB_DISABLE = "true";
          UP_PROMETHEUS_HTTP_LISTEN = "0.0.0.0:9130";
          UP_PROMETHEUS_NAMESPACE = "unpoller";
          UP_POLLER_DEBUG = "false";
          UP_POLLER_QUIET = "false";
        };
        environmentFiles = ["/run/opnix/monitoring-unpoller-env"];
      };
    };

    containers.monitoring-grafana = {
      unitConfig = {
        After = [
          "opnix-secrets.service"
          "monitoring-env-setup.service"
          "monitoring-prometheus.service"
          "monitoring-loki.service"
        ];
        Requires = [
          "opnix-secrets.service"
          "monitoring-env-setup.service"
          "monitoring-prometheus.service"
          "monitoring-loki.service"
        ];
      };
      containerConfig = {
        image = "docker.io/grafana/grafana:latest";
        autoUpdate = "registry";
        networks = [networks.monitoring_network.ref networks.traefik_network.ref];
        environments = {
          GF_SECURITY_ADMIN_USER = "admin";
          GF_SERVER_ROOT_URL = "https://grafana.jennex.dev";
          GF_INSTALL_PLUGINS = "grafana-clock-panel,natel-discrete-panel,grafana-piechart-panel";
          GF_PATHS_PROVISIONING = "/etc/grafana/provisioning";
          GF_AUTH_DISABLE_LOGIN_FORM = "true";
          GF_AUTH_BASIC_ENABLED = "false";
          GF_AUTH_PROXY_ENABLED = "true";
          GF_AUTH_PROXY_HEADER_NAME = "X-Forwarded-User";
          GF_AUTH_PROXY_HEADER_PROPERTY = "email";
          GF_AUTH_PROXY_AUTO_SIGN_UP = "true";
        };
        environmentFiles = ["/run/opnix/monitoring-grafana-env"];
        volumes = [
          "${volumes.monitoring-grafana.ref}:/var/lib/grafana"
          "${grafanaDatasources}:/etc/grafana/provisioning/datasources/datasources.yaml:ro"
        ];
        labels = [
          "homepage.group=Network"
          "homepage.name=Grafana"
          "homepage.icon=grafana.png"
          "homepage.href=https://grafana.jennex.dev"
          "homepage.description=Monitoring & Metrics"
          "traefik.enable=true"
          "traefik.http.routers.grafana-secure.entrypoints=https"
          "traefik.http.routers.grafana-secure.rule=Host(`grafana.jennex.dev`)"
          "traefik.http.routers.grafana-secure.tls=true"
          "traefik.http.routers.grafana-secure.middlewares=forward-auth"
          "traefik.http.services.monitoring-grafana.loadbalancer.server.port=3000"
        ];
      };
    };
  };
}

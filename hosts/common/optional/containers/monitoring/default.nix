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

      - job_name: node
        static_configs:
          - targets: ['10.1.30.100:9100']

      - job_name: podman
        static_configs:
          - targets: ['monitoring-podman-exporter:9882']
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


  grafanaDashboardProvider = pkgs.writeText "dashboards-provider.yaml" ''
    apiVersion: 1
    providers:
      - name: provisioned
        type: file
        disableDeletion: false
        allowUiUpdates: true
        updateIntervalSeconds: 60
        options:
          path: /etc/grafana/provisioning/dashboards
  '';

  grafanaDashboardNauvoo = pkgs.writeText "nauvoo-overview.json" ''
    {
      "annotations": { "list": [] },
      "editable": true,
      "graphTooltip": 1,
      "links": [],
      "panels": [
        {
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "fieldConfig": {
            "defaults": {
              "color": { "mode": "palette-classic" },
              "custom": { "lineWidth": 2, "fillOpacity": 10 },
              "unit": "percent",
              "min": 0,
              "max": 100
            },
            "overrides": []
          },
          "gridPos": { "h": 8, "w": 8, "x": 0, "y": 0 },
          "id": 1,
          "options": {
            "legend": { "calcs": ["mean", "max", "lastNotNull"], "displayMode": "list", "placement": "bottom" },
            "tooltip": { "mode": "single" }
          },
          "targets": [
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
              "legendFormat": "CPU %",
              "refId": "A"
            }
          ],
          "title": "CPU Usage",
          "type": "timeseries"
        },
        {
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "fieldConfig": {
            "defaults": {
              "color": { "mode": "palette-classic" },
              "custom": { "lineWidth": 2, "fillOpacity": 10 },
              "unit": "percent",
              "min": 0,
              "max": 100
            },
            "overrides": []
          },
          "gridPos": { "h": 8, "w": 8, "x": 0, "y": 8 },
          "id": 2,
          "options": {
            "legend": { "calcs": ["mean", "max", "lastNotNull"], "displayMode": "list", "placement": "bottom" },
            "tooltip": { "mode": "single" }
          },
          "targets": [
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
              "legendFormat": "Memory %",
              "refId": "A"
            }
          ],
          "title": "Memory Usage",
          "type": "timeseries"
        },
        {
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "fieldConfig": {
            "defaults": {
              "color": { "mode": "palette-classic" },
              "custom": { "lineWidth": 2, "fillOpacity": 5 },
              "unit": "binBps"
            },
            "overrides": []
          },
          "gridPos": { "h": 8, "w": 8, "x": 0, "y": 16 },
          "id": 3,
          "options": {
            "legend": { "calcs": [], "displayMode": "list", "placement": "bottom" },
            "tooltip": { "mode": "multi" }
          },
          "targets": [
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "irate(node_network_receive_bytes_total{device!~\"lo|veth.*|br-.*\"}[5m])",
              "legendFormat": "RX {{device}}",
              "refId": "A"
            },
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "irate(node_network_transmit_bytes_total{device!~\"lo|veth.*|br-.*\"}[5m])",
              "legendFormat": "TX {{device}}",
              "refId": "B"
            }
          ],
          "title": "Network I/O",
          "type": "timeseries"
        },
        {
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "fieldConfig": {
            "defaults": {
              "color": { "mode": "palette-classic" },
              "custom": { "lineWidth": 2, "fillOpacity": 5 },
              "unit": "binBps"
            },
            "overrides": []
          },
          "gridPos": { "h": 8, "w": 8, "x": 0, "y": 24 },
          "id": 4,
          "options": {
            "legend": { "calcs": [], "displayMode": "list", "placement": "bottom" },
            "tooltip": { "mode": "multi" }
          },
          "targets": [
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "irate(node_disk_read_bytes_total{device!~\"sr.*|loop.*\"}[5m])",
              "legendFormat": "Read {{device}}",
              "refId": "A"
            },
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "irate(node_disk_written_bytes_total{device!~\"sr.*|loop.*\"}[5m])",
              "legendFormat": "Write {{device}}",
              "refId": "B"
            }
          ],
          "title": "Disk I/O",
          "type": "timeseries"
        },
        {
          "datasource": { "type": "loki", "uid": "loki" },
          "gridPos": { "h": 32, "w": 16, "x": 8, "y": 0 },
          "id": 5,
          "options": {
            "dedupStrategy": "none",
            "enableLogDetails": true,
            "prettifyLogMessage": false,
            "showLabels": true,
            "showCommonLabels": false,
            "showTime": true,
            "sortOrder": "Descending",
            "wrapLogMessage": false
          },
          "targets": [
            {
              "datasource": { "type": "loki", "uid": "loki" },
              "expr": "{job=\"systemd-journal\",host=\"nauvoo\",unit=~\"$unit\"}",
              "refId": "A"
            }
          ],
          "title": "Logs",
          "type": "logs"
        }
      ],
      "refresh": "30s",
      "schemaVersion": 38,
      "tags": ["nauvoo", "system"],
      "templating": {
        "list": [
          {
            "allValue": ".*",
            "current": {},
            "datasource": { "type": "loki", "uid": "loki" },
            "definition": "label_values({job=\"systemd-journal\",host=\"nauvoo\"}, unit)",
            "hide": 0,
            "includeAll": true,
            "label": "Unit",
            "multi": false,
            "name": "unit",
            "options": [],
            "query": {
              "label": "unit",
              "queryType": "labelValues",
              "refId": "StandardVariableQuery",
              "stream": "{job=\"systemd-journal\",host=\"nauvoo\"}"
            },
            "refresh": 2,
            "type": "query"
          }
        ]
      },
      "time": { "from": "now-1h", "to": "now" },
      "timepicker": {},
      "timezone": "browser",
      "title": "Nauvoo Overview",
      "uid": "nauvoo-overview",
      "version": 1
    }
  '';

  grafanaDashboardContainers = pkgs.writeText "containers-overview.json" ''
    {
      "annotations": { "list": [] },
      "editable": true,
      "graphTooltip": 1,
      "links": [],
      "panels": [
        {
          "collapsed": false,
          "gridPos": { "h": 1, "w": 24, "x": 0, "y": 0 },
          "id": 10,
          "repeat": "container",
          "repeatDirection": "v",
          "title": "$container",
          "type": "row"
        },
        {
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "fieldConfig": {
            "defaults": {
              "color": { "mode": "palette-classic" },
              "custom": { "lineWidth": 2, "fillOpacity": 10 }
            },
            "overrides": [
              {
                "matcher": { "id": "byName", "options": "CPU %" },
                "properties": [
                  { "id": "unit", "value": "percent" },
                  { "id": "min", "value": 0 },
                  { "id": "custom.axisPlacement", "value": "left" },
                  { "id": "color", "value": { "mode": "fixed", "fixedColor": "#7aa2f7" } }
                ]
              },
              {
                "matcher": { "id": "byName", "options": "Memory" },
                "properties": [
                  { "id": "unit", "value": "bytes" },
                  { "id": "custom.axisPlacement", "value": "right" },
                  { "id": "color", "value": { "mode": "fixed", "fixedColor": "#bb9af7" } }
                ]
              }
            ]
          },
          "gridPos": { "h": 8, "w": 8, "x": 0, "y": 1 },
          "id": 1,
          "options": {
            "legend": { "calcs": ["mean", "max", "lastNotNull"], "displayMode": "list", "placement": "bottom" },
            "tooltip": { "mode": "multi" }
          },
          "targets": [
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "sum by (name) (rate(podman_container_cpu_seconds_total{name=\"$container\"}[5m])) * 100",
              "legendFormat": "CPU %",
              "refId": "A"
            },
            {
              "datasource": { "type": "prometheus", "uid": "prometheus" },
              "expr": "podman_container_mem_usage_bytes{name=\"$container\"}",
              "legendFormat": "Memory",
              "refId": "B"
            }
          ],
          "title": "Resources",
          "type": "timeseries"
        },
        {
          "datasource": { "type": "loki", "uid": "loki" },
          "gridPos": { "h": 8, "w": 16, "x": 8, "y": 1 },
          "id": 2,
          "options": {
            "dedupStrategy": "none",
            "enableLogDetails": true,
            "prettifyLogMessage": false,
            "showLabels": false,
            "showCommonLabels": false,
            "showTime": true,
            "sortOrder": "Descending",
            "wrapLogMessage": true
          },
          "targets": [
            {
              "datasource": { "type": "loki", "uid": "loki" },
              "expr": "{job=\"systemd-journal\",host=\"nauvoo\",unit=~\"$container.*\"}",
              "refId": "A"
            }
          ],
          "title": "Logs",
          "type": "logs"
        }
      ],
      "refresh": "30s",
      "schemaVersion": 38,
      "tags": ["nauvoo", "containers"],
      "templating": {
        "list": [
          {
            "current": {},
            "datasource": { "type": "prometheus", "uid": "prometheus" },
            "definition": "label_values(podman_container_cpu_seconds_total, name)",
            "hide": 0,
            "includeAll": true,
            "label": "Container",
            "multi": true,
            "name": "container",
            "options": [],
            "query": {
              "query": "label_values(podman_container_cpu_seconds_total, name)",
              "refId": "StandardVariableQuery"
            },
            "refresh": 2,
            "sort": 1,
            "type": "query"
          }
        ]
      },
      "time": { "from": "now-1h", "to": "now" },
      "timepicker": {},
      "timezone": "browser",
      "title": "Container Resources",
      "uid": "container-overview",
      "version": 4
    }
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
            printf 'GF_SECURITY_ADMIN_PASSWORD=%s\n'              "$(cat /run/opnix/monitoring-grafana-admin-password)"
            printf 'GF_AUTH_GENERIC_OAUTH_CLIENT_ID=%s\n'         "$(cat /run/opnix/monitoring-grafana-oidc-client-id)"
            printf 'GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=%s\n'     "$(cat /run/opnix/monitoring-grafana-oidc-client-secret)"
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
        publishPorts = ["127.0.0.1:3100:3100"];
        volumes = [
          "${lokiConfig}:/etc/loki/local-config.yaml:ro"
          "${volumes.monitoring-loki.ref}:/loki"
        ];
      };
    };


    containers.monitoring-podman-exporter = {
      containerConfig = {
        image = "quay.io/navidys/prometheus-podman-exporter:latest";
        autoUpdate = "registry";
        networks = [networks.monitoring_network.ref];
        user = "root";
        exec = "--collector.enhance-metrics --collector.enable-all";
        volumes = ["/run/podman/podman.sock:/run/podman/podman.sock"];
        environments = {
          CONTAINER_HOST = "unix:///run/podman/podman.sock";
        };
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
          GF_AUTH_DISABLE_LOGIN_FORM = "false";
          GF_AUTH_BASIC_ENABLED = "true";
          GF_AUTH_GENERIC_OAUTH_AUTO_LOGIN = "false";
          GF_AUTH_GENERIC_OAUTH_ENABLED = "true";
          GF_AUTH_GENERIC_OAUTH_NAME = "Pocket ID";
          GF_AUTH_GENERIC_OAUTH_SCOPES = "openid email profile";
          GF_AUTH_GENERIC_OAUTH_AUTH_URL = "https://pocket.jennex.dev/authorize";
          GF_AUTH_GENERIC_OAUTH_TOKEN_URL = "https://pocket.jennex.dev/api/oidc/token";
          GF_AUTH_GENERIC_OAUTH_API_URL = "https://pocket.jennex.dev/api/oidc/userinfo";
          GF_AUTH_GENERIC_OAUTH_EMAIL_ATTRIBUTE_PATH = "email";
          GF_AUTH_GENERIC_OAUTH_NAME_ATTRIBUTE_PATH = "name";
          GF_AUTH_GENERIC_OAUTH_AUTO_SIGN_UP = "true";
          GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_STRICT = "false";
          GF_AUTH_GENERIC_OAUTH_USE_PKCE = "true";
          GF_USERS_AUTO_ASSIGN_ORG = "true";
          GF_USERS_AUTO_ASSIGN_ORG_ROLE = "Admin";
          GF_USERS_ALLOW_SIGN_UP = "true";
          GF_LOG_FILTERS = "oauth.generic_oauth:debug";
        };
        environmentFiles = ["/run/opnix/monitoring-grafana-env"];
        volumes = [
          "${volumes.monitoring-grafana.ref}:/var/lib/grafana"
          "${grafanaDatasources}:/etc/grafana/provisioning/datasources/datasources.yaml:ro"
          "${grafanaDashboardProvider}:/etc/grafana/provisioning/dashboards/provider.yaml:ro"
          "${grafanaDashboardNauvoo}:/etc/grafana/provisioning/dashboards/nauvoo-overview.json:ro"
          "${grafanaDashboardContainers}:/etc/grafana/provisioning/dashboards/containers-overview.json:ro"
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
          "traefik.http.services.monitoring-grafana.loadbalancer.server.port=3000"
        ];
      };
    };
  };

  # node_exporter runs on the host so Prometheus can scrape system metrics
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/promtail 0750 promtail promtail -"
  ];

  # Promtail runs as a NixOS service — the Docker image lacks systemd journal support
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };
      positions.filename = "/var/lib/promtail/positions.yaml";
      clients = [{url = "http://127.0.0.1:3100/loki/api/v1/push";}];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "nauvoo";
            };
          };
          relabel_configs = [
            {source_labels = ["__journal__systemd_unit"]; target_label = "unit";}
            {source_labels = ["__journal__hostname"]; target_label = "hostname";}
            {source_labels = ["__journal__container_name"]; target_label = "container";}
            {source_labels = ["__journal__image_name"]; target_label = "image";}
          ];
        }
      ];
    };
  };

  systemd.services.promtail = {
    after = ["monitoring-loki.service"];
    wants = ["monitoring-loki.service"];
  };
}

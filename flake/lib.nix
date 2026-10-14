{inputs, ...}: {
  flake.lib = {
    mkNixos = {
      system,
      modules,
      extraSpecialArgs ? {},
    }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs =
          {
            inherit inputs;
            outputs = inputs.self.outputs;
          }
          // extraSpecialArgs;
      };

    mkDarwin = {
      system,
      modules,
      extraSpecialArgs ? {},
    }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system modules;
        specialArgs =
          {
            inherit inputs;
            outputs = inputs.self.outputs;
          }
          // extraSpecialArgs;
      };

    # Homepage + Traefik container labels for a web service on nauvoo
    # (aspects/nixos/containers/*.nix). Produces the standard label set in a
    # fixed order:
    #   homepage.{group,name,icon,href,description}   (when `homepage` is set)
    #   traefik.enable, a plain router (unless secureOnly), the "<router>-secure"
    #   router on the https entrypoint with TLS, and the service port.
    # TLS uses the wildcard cert configured on the https entrypoint, and
    # homepage.href defaults to the service's own URL.
    #
    #   labels = self.lib.webLabels {
    #     host = "it-tools.jennex.dev";
    #     router = "it_tools";
    #     port = 80;
    #     homepage = {group = "Dev & Games"; name = "IT Tools"; icon = "it-tools.png"; description = "Helpful Tools";};
    #   };
    webLabels = {
      host,
      router,
      port,
      homepage ? null,
      secureOnly ? false,
    }: let
      inherit (inputs.nixpkgs) lib;
      rule = "Host(`${host}`)";
    in
      lib.optionals (homepage != null) [
        "homepage.group=${homepage.group}"
        "homepage.name=${homepage.name}"
        "homepage.icon=${homepage.icon}"
        "homepage.href=${homepage.href or "https://${host}"}"
        "homepage.description=${homepage.description}"
      ]
      ++ ["traefik.enable=true"]
      ++ lib.optional (!secureOnly) "traefik.http.routers.${router}.rule=${rule}"
      ++ [
        "traefik.http.routers.${router}-secure.entrypoints=https"
        "traefik.http.routers.${router}-secure.rule=${rule}"
        "traefik.http.routers.${router}-secure.tls=true"
        "traefik.http.services.${router}.loadbalancer.server.port=${toString port}"
      ];
  };
}

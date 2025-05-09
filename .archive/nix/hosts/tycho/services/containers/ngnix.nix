{config, ...}: {
  virtualisation.oci-containers.containers."nginx" = {
    image = "docker.io/nginx:alping";
    enviromentFiles = [
      config.age.secrets.secret1.path
    ];
  };
}

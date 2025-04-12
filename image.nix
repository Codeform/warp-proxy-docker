{pkgs, ...}: let
  entryScript =
    pkgs.writeScriptBin "entrypoint"
    ''
      #!/bin/sh
      wgcf register --accept-tos
      wgcf generate
      echo '[Socks5]' >> wgcf-profile.conf
      echo 'BindAddress = 0.0.0.0:25555' >> wgcf-profile.conf
      wireproxy -c wgcf-profile.conf -i 0.0.0.0:25556
    '';
  healthcheckScript =
    pkgs.writeScriptBin "healthcheck"
    ''
      #!/bin/sh
      HTTPS_PROXY=socks5://localhost:25555 wgcf trace | grep -qE "warp=(plus|on)"
    '';
in
  pkgs.dockerTools.streamLayeredImage {
    name = "warp-proxy";
    tag = "main";

    contents = [
      pkgs.busybox
      pkgs.dockerTools.caCertificates
      pkgs.wgcf
      pkgs.wireproxy
      entryScript
      healthcheckScript
    ];

    config = {
      Entrypoint = [
        "entrypoint"
      ];
      HealthCheck = {
        Test = ["healthcheck"];
        Interval = 120 * 1000000000;
        Timeout = 15 * 1000000000;
        StartPeriod = 60 * 1000000000;
        Retries = 3;
      };
    };
  }

{
  pkgs,
  lib,
  ...
}: let
  entryScript =
    pkgs.writeScriptBin "entrypoint"
    ''
      #!${pkgs.runtimeShell}
      ${lib.getExe pkgs.wgcf} register --accept-tos
      ${lib.getExe pkgs.wgcf} generate
      echo '[Socks5]' >> wgcf-profile.conf
      echo 'BindAddress = 0.0.0.0:25555' >> wgcf-profile.conf
      ${lib.getExe pkgs.wireproxy} -c wgcf-profile.conf -i 0.0.0.0:25556
    '';
  healthcheckScript =
    pkgs.writeScriptBin "healthcheck"
    ''
    '';
in
  pkgs.dockerTools.streamLayeredImage {
    name = "warp-proxy";
    tag = "main";

    contents = [
      pkgs.dockerTools.caCertificates
      entryScript
    ];

    config = {
      Entrypoint = [
        "entrypoint"
      ];
    };
  }

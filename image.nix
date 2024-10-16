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
      echo 'BindAddress = 127.0.0.1:25555' >> wgcf-profile.conf
      ${lib.getExe pkgs.wireproxy} -c wgcf-profile.conf -i 127.0.0.1:25556
    '';
  healthcheckScript =
    pkgs.writeScriptBin "healthcheck"
    ''
    '';
in
  pkgs.dockerTools.buildLayeredImage {
    name = "warp-proxy";
    tag = "lastest";

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

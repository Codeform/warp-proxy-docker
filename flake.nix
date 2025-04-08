{
  description = "Simple cloudflare warp and socks5 proxy docker image";
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  outputs = {nixpkgs, ...}: let
    pkgs = nixpkgs.legacyPackages.${system};
    system = "x86_64-linux";
    imagePkg = pkgs.callPackage ./image.nix {};
    shell =
      pkgs.writeShellScript "main"
      ''
        ${imagePkg} | ${pkgs.lib.getExe pkgs.podman} load
        ${pkgs.lib.getExe pkgs.podman} run --rm -it -p 0.0.0.0:25555-25556:25555-25556 localhost/warp-proxy:lastest
      '';
  in {
    packages.${system} = {default = imagePkg;};

    apps.${system}.default = {
      type = "app";
      program = shell.outPath;
    };

    devShells.${system} = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          nil
          podman
        ];
      };
    };
  };
}

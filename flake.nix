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
  in {
    packages.${system} = {default = pkgs.callPackage ./image.nix {};};

    devShells.${system} = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          nil
        ];
      };
    };
  };
}

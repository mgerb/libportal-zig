{
  description = "libportal-zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    zig,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = {
        zls = pkgs.stdenv.mkDerivation {
          pname = "zls";
          version = "0.17.0-dev.44+8da87d4f";
          src = pkgs.fetchurl {
            url = "https://builds.zigtools.org/zls-x86_64-linux-0.17.0-dev.44+8da87d4f.tar.xz";
            sha256 = "sha256-nqIj+ohCRnFVWRG+ul1okZGuCApOgn71x2yPZOOf8pY=";
          };
          sourceRoot = ".";
          installPhase = ''
            mkdir -p $out/bin
            mv zls $out/bin/
          '';
        };
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          zig.packages.${system}.master
          self.packages.${system}.zls
          glib
          pkg-config
        ];

        shellHook = ''

        '';
      };
    });
}

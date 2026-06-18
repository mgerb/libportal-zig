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
          version = "0.16.0";
          src = pkgs.fetchurl {
            url = "https://builds.zigtools.org/zls-x86_64-linux-0.16.0.tar.xz";
            sha256 = "sha256-3tbVYqC4buh4sd33D/qyeXzjzco7AtYHdUj51W3/lrY=";
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
          zig.packages.${system}."0.16.0"
          self.packages.${system}.zls
          glib
          pkg-config
        ];

        shellHook = ''

        '';
      };
    });
}

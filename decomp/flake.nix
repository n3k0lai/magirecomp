{
  description = "Magi-Nation Game Boy Color disassembly toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mgbdis = {
      url = "github:mattcurrie/mgbdis/v3.0";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, mgbdis }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          f pkgs
        );
      mgbdisScript =
        pkgs:
        pkgs.writeShellScriptBin "mgbdis" ''
          exec ${pkgs.python3}/bin/python3 ${mgbdis}/mgbdis.py "$@"
        '';
    in
    {
      packages = forEachSystem (pkgs: {
        mgbdis = mgbdisScript pkgs;
        default = mgbdisScript pkgs;
      });

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            (mgbdisScript pkgs)
            pkgs.rgbds
            pkgs.python3
            pkgs.gnumake
            pkgs.diffutils
            pkgs.which
            pkgs.jq
            pkgs.curl
          ];
        };
      });
    };
}

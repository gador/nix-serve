{
  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:

    let
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" ];
    in {

      overlay = final: prev: {
        nix-serve = final.pkgs.callPackage ./package.nix {
          inherit self;
        };
      };

      packages = forAllSystems (system: {
        nix-serve = nixpkgs.legacyPackages.${system}.callPackage ./package.nix {
          inherit self;
        };
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.nix-serve);

      checks = forAllSystems (system: {
        build = self.defaultPackage.${system};
        # FIXME: add a proper test.
      });

    };
}

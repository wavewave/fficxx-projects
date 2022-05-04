{
  description = "HROOT examples";
  inputs = {
    fficxx = { url = "/home/wavewave/repo/src/fficxx"; };
    fficxx-projects = { url = "github:wavewave/fficxx-projects/master"; };
  };
  outputs = { self, fficxx, fficxx-projects }:
    let
      pkgs = import (fficxx-projects.inputs.nixpkgs) {
        overlays = [ fficxx.overlay fficxx-projects.overlay ];
        system = "x86_64-linux";
        config = { allowBroken = true; };
      };

    in {
      devShell.x86_64-linux = with pkgs;
        let
          hsenv = pkgs.haskellPackages.ghcWithPackages
            (p: [ p.cabal-install p.HROOT p.monad-loops ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

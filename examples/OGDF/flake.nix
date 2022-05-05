{
  description = "hgdal examples";
  inputs = {
    fficxx = { url = "/home/wavewave/repo/src/fficxx"; };
    hs-ogdf = { url = "github:wavewave/hs-ogdf/master"; };
    fficxx-projects = { url = "github:wavewave/fficxx-projects/master"; };
  };
  outputs = { self, fficxx, hs-ogdf, fficxx-projects }:
    let
      pkgs = import (fficxx-projects.inputs.nixpkgs) {
        overlays = [ fficxx.overlay hs-ogdf.overlay ];
        system = "x86_64-linux";
        config = { allowBroken = true; };
      };

    in {
      devShell.x86_64-linux = with pkgs;
        let
          hsenv = pkgs.haskellPackages.ghcWithPackages
            (p: [ p.cabal-install p.OGDF p.formatting p.monad-loops ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

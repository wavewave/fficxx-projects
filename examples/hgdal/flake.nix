{
  description = "hgdal examples";
  inputs = {
    fficxx = { url = "github:wavewave/fficxx/0.6"; };
    hgdal = { url = "github:wavewave/hgdal/master"; };
    fficxx-projects = { url = "github:wavewave/fficxx-projects/master"; };
  };
  outputs = { self, fficxx, hgdal, fficxx-projects }:
    let
      pkgs = import (fficxx-projects.inputs.nixpkgs) {
        overlays = [ fficxx.overlay hgdal.overlay ];
        system = "x86_64-linux";
        config = { allowBroken = true; };
      };

    in {
      devShell.x86_64-linux = with pkgs;
        let
          hsenv = pkgs.haskellPackages.ghcWithPackages
            (p: [ p.cabal-install p.hgdal p.monad-loops ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

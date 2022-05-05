{
  description = "HROOT examples";
  inputs = {
    fficxx = { url = "github:wavewave/fficxx/0.6"; };
    HROOT = { url = "github:wavewave/HROOT/master"; };
    fficxx-projects = { url = "github:wavewave/fficxx-projects/master"; };
  };
  outputs = { self, fficxx, HROOT, fficxx-projects }:
    let
      pkgs = import (fficxx-projects.inputs.nixpkgs) {
        overlays = [ fficxx.overlay HROOT.overlay ];
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

{
  description = "HROOT examples";
  inputs = {
    fficxx-projects = { url = "github:wavewave/fficxx-projects/master"; };

  };
  outputs = { self, fficxx-projects }:
    let
      pkgs = import (fficxx-projects.inputs.nixpkgs) {
        overlays = [ fficxx-projects.overlay ];
        system = "x86_64-linux";
        config = { allowBroken = true; };
      };

    in {
      devShell.x86_64-linux = with pkgs;
        let
          hsenv = pkgs.haskellPackages.ghcWithPackages
            (p: with p; [ cabal-install HROOT monad-loops ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

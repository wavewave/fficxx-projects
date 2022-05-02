{
  description = "hgdal examples";
  inputs = {
    fficxx-projects = {
      url = "../.."; # "github:wavewave/fficxx-projects/master";
    };

  };
  outputs = { self, fficxx-projects }:
    let pkgs = fficxx-projects.inputs.nixpkgs.legacyPackages.x86_64-linux;

    in {
      devShell.x86_64-linux = with pkgs;
        let
          hsenv =
            fficxx-projects.legacyPackages.x86_64-linux.haskellPackages.ghcWithPackages
            (p: with p; [ cabal-install hgdal monad-loops ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

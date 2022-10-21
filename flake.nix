{
  description = "fficxx projects";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";    
    fficxx = {
      url = "github:wavewave/fficxx/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    HROOT = {
      url = "github:wavewave/HROOT/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fficxx.follows = "fficxx";
    };
    hgdal = {
      url = "github:wavewave/hgdal/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fficxx.follows = "fficxx";
    };
    hs-ogdf = {
      url = "github:wavewave/hs-ogdf/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fficxx.follows = "fficxx";
    };

  };
  outputs = { self, nixpkgs, flake-utils, fficxx, HROOT, hgdal, hs-ogdf }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays =
            [ fficxx.overlay.${system}
              HROOT.overlay.${system}
              hs-ogdf.overlay.${system}
              hgdal.overlay.${system}
            ];
          inherit system;
        };

        mkDevShell = hsPkgs: otherPkgs:
          let
            hsenv = pkgs.haskellPackages.ghcWithPackages (allHsPkgs:
              builtins.map (pkg: builtins.getAttr pkg allHsPkgs) hsPkgs);
          in pkgs.mkShell { buildInputs = [ hsenv ] ++ otherPkgs; };

      in {
        packages = {
          inherit (pkgs) ogdf;
          inherit (pkgs.haskellPackages)
            fficxx-runtime fficxx stdcxx HROOT HROOT-core HROOT-graf HROOT-hist
            HROOT-io HROOT-math HROOT-net HROOT-tree HROOT-RooFit
            HROOT-RooFit-RooStats hgdal OGDF;
          #inherit HROOT-env hgdal-env OGDF-env;

        };

        devShells = rec {
          default = vanilla;
          vanilla = mkDevShell [ "cabal-install" "fficxx" "stdcxx" ] [ ];
          HROOT = mkDevShell [ "cabal-install" "HROOT" "monad-loops" ] [ ];
          hgdal = mkDevShell [ "cabal-install" "hgdal" "monad-loops" ] [ ];
          OGDF =
            mkDevShell [ "cabal-install" "OGDF" "formatting" "monad-loops" ] [ ];
        };

      }
 );
}

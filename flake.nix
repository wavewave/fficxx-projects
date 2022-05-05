{
  description = "fficxx projects";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
    fficxx = {
      url = "github:wavewave/fficxx/0.6";
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
  outputs = { self, nixpkgs, fficxx, HROOT, hgdal, hs-ogdf }:
    let
      pkgs = import nixpkgs {
        overlays =
          [ fficxx.overlay HROOT.overlay hgdal.overlay hs-ogdf.overlay ];
        system = "x86_64-linux";
      };

      mkEnv = pkgname:
        let
          hsenv = pkgs.haskellPackages.ghcWithPackages
            (p: [ (builtins.getAttr pkgname p) ]);
        in pkgs.mkShell { buildInputs = [ hsenv ]; };

      HROOT-env = mkEnv "HROOT";
      hgdal-env = mkEnv "hgdal";
      OGDF-env = mkEnv "OGDF";

    in {
      packages.x86_64-linux = {
        inherit (pkgs) ogdf;
        inherit (pkgs.haskellPackages)
          fficxx-runtime fficxx stdcxx HROOT HROOT-core HROOT-graf HROOT-hist
          HROOT-io HROOT-math HROOT-net HROOT-tree HROOT-RooFit
          HROOT-RooFit-RooStats hgdal OGDF;
        inherit HROOT-env hgdal-env OGDF-env;

      };

      devShell.x86_64-linux = with pkgs;
        let
          hsenv = haskellPackages.ghcWithPackages
            (p: [ p.cabal-install p.fficxx p.fficxx-runtime p.stdcxx ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

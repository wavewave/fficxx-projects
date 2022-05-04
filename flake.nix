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
      flake = false;
    };
    hgdal = {
      url = "github:wavewave/hgdal/master";
      flake = false;
    };
    hs-ogdf = {
      url = "github:wavewave/hs-ogdf/master";
      flake = false;
    };

  };
  outputs = { self, nixpkgs, fficxx, HROOT, hgdal, hs-ogdf }:
    let
      pkgs = import nixpkgs {
        overlays = [ fficxx.overlay ];
        system = "x86_64-linux";
      };

      ogdf = pkgs.callPackage (hs-ogdf + "/ogdf") { };

      finalHaskellOverlay = self: super:
        (import HROOT {
          inherit pkgs;
          fficxxSrc = fficxx;
        } self super) // (import hgdal {
          inherit pkgs;
          fficxxSrc = fficxx;
        } self super) // (import hs-ogdf {
          inherit pkgs ogdf;
          fficxxSrc = fficxx;
        } self super);

      newHaskellPackages = pkgs.haskellPackages.extend finalHaskellOverlay;

      mkEnv = pkgname:
        let
          hsenv = newHaskellPackages.ghcWithPackages
            (p: [ (builtins.getAttr pkgname p) ]);
        in pkgs.mkShell { buildInputs = [ hsenv ]; };

      HROOT-env = mkEnv "HROOT";
      hgdal-env = mkEnv "hgdal";
      OGDF-env = mkEnv "OGDF";

    in {
      packages.x86_64-linux = {
        inherit ogdf;
        stdcxx = pkgs.haskellPackages.stdcxx;

        inherit (newHaskellPackages)
          HROOT HROOT-core HROOT-graf HROOT-hist HROOT-io HROOT-math HROOT-net
          HROOT-tree HROOT-RooFit HROOT-RooFit-RooStats hgdal OGDF;
        inherit HROOT-env hgdal-env OGDF-env;

      };

      # see these issues and discussions:
      # - https://github.com/NixOS/nixpkgs/issues/16394
      # - https://github.com/NixOS/nixpkgs/issues/25887
      # - https://github.com/NixOS/nixpkgs/issues/26561
      # - https://discourse.nixos.org/t/nix-haskell-development-2020/6170
      overlay = final: prev: {
        haskellPackages = prev.haskellPackages.override (old: {
          overrides = final.lib.composeExtensions (old.overrides or (_: _: { }))
            finalHaskellOverlay;
        });
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

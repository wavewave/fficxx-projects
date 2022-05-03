{
  description = "fficxx projects";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
    fficxx = {
      url = "github:wavewave/fficxx/0.6";
      flake = false;
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
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      haskellPackages = pkgs.haskell.packages.ghc865;
      newHaskellPackages0 = haskellPackages.override {
        overrides = self: super: {
          "fficxx-runtime" =
            self.callCabal2nix "fficxx-runtime" (fficxx + "/fficxx-runtime")
            { };
          "fficxx" = self.callCabal2nix "fficxx" (fficxx + "/fficxx") { };
        };
      };

      stdcxxSrc = import (fficxx + "/stdcxx-gen/gen.nix") {
        inherit (pkgs) stdenv;
        haskellPackages = newHaskellPackages0;
      };

      ogdf = pkgs.callPackage (hs-ogdf + "/ogdf") { };

      finalHaskellOverlay = self: super:
        {
          "fficxx-runtime" =
            self.callCabal2nix "fficxx-runtime" (fficxx + "/fficxx-runtime")
            { };
          "fficxx" = self.callCabal2nix "fficxx" (fficxx + "/fficxx") { };
          "stdcxx" = self.callCabal2nix "stdcxx" stdcxxSrc { };
        } // (import HROOT {
          inherit pkgs;
          fficxxSrc = fficxx;
        } self super) // (import hgdal {
          inherit pkgs;
          fficxxSrc = fficxx;
        } self super) // (import hs-ogdf {
          inherit pkgs ogdf;
          fficxxSrc = fficxx;
        } self super);

      newHaskellPackages = haskellPackages.override {
        overrides = finalHaskellOverlay;

      };

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
        inherit (newHaskellPackages)
          fficxx fficxx-runtime stdcxx HROOT HROOT-core HROOT-graf HROOT-hist
          HROOT-io HROOT-math HROOT-net HROOT-tree HROOT-RooFit
          HROOT-RooFit-RooStats hgdal OGDF;
        inherit HROOT-env hgdal-env OGDF-env;

      };

      overlay = final: prev: {
        haskellPackages = prev.haskell.packages.ghc865.override {
          overrides = finalHaskellOverlay;
        };
      };

      devShell.x86_64-linux = with pkgs;
        let
          hsenv = haskell.packages.ghc865.ghcWithPackages
            (p: with p; [ cabal-install ]);
        in mkShell {
          buildInputs = [ hsenv ];
          shellHook = "";
        };
    };
}

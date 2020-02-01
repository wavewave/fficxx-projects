{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  # TODO: should be packaged into the upstream nixpkgs.
  ogdf = callPackage ./hs-ogdf/ogdf/default.nix {};
  DataFrame = callPackage ./HDataFrame/DataFrame/default.nix {};

  fficxxSrc = lib.cleanSource ./fficxx;

  newHaskellPackages0 = haskellPackages.override {
    overrides = self: super: {
      "fficxx-runtime" = self.callCabal2nix "fficxx-runtime" (fficxxSrc + "/fficxx-runtime") {};
      "fficxx"         = self.callCabal2nix "fficxx"         (fficxxSrc + "/fficxx")         {};
    };
  };

  stdcxxSrc = import (fficxxSrc + "/stdcxx-gen/gen.nix") {
    inherit stdenv;
    haskellPackages = newHaskellPackages0;
  };

  newHaskellPackages = haskellPackages.override {
    overrides = self: super:
      {
        "fficxx-runtime" = self.callCabal2nix "fficxx-runtime" (fficxxSrc + "/fficxx-runtime") {};
        "fficxx"         = self.callCabal2nix "fficxx"         (fficxxSrc + "/fficxx")         {};
        "stdcxx"         = self.callCabal2nix "stdcxx"         stdcxxSrc                       {};
      }
      // (import ./HROOT   { inherit pkgs fficxxSrc; } self super)
      // (import ./hgdal   { inherit pkgs fficxxSrc; } self super)
      // (import ./hs-ogdf { inherit pkgs fficxxSrc ogdf; } self super);
  };

in

{

  "fficxx"         = newHaskellPackages.fficxx;
  "fficxx-runtime" = newHaskellPackages.fficxx-runtime;
  "stdcxx"         = newHaskellPackages.stdcxx;
  "HROOT"          = newHaskellPackages.HROOT;
  "hgdal"          = newHaskellPackages.hgdal;
  "OGDF"           = newHaskellPackages.OGDF;
  "DataFrame"      = DataFrame;
}

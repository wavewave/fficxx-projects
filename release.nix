{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let

  fficxxSrc = lib.cleanSource ./fficxx;

  newHaskellPackages0 = haskellPackages.override {
    overrides = self: super: {
      "fficxx-runtime" = self.callCabal2nix "fficxx-runtime" (fficxxSrc + "/fficxx-runtime") {};
      "fficxx"         = self.callCabal2nix "fficxx"         (fficxxSrc + "/fficxx")         {};
    };
  };

  stdcxxNix = import (fficxxSrc + "/stdcxx-gen/default.nix") {
    inherit stdenv;
    haskellPackages = newHaskellPackages0;
  };

  newHaskellPackages = haskellPackages.override {
    overrides = self: super:
      {
        "fficxx-runtime" = self.callCabal2nix "fficxx-runtime" (fficxxSrc + "/fficxx-runtime") {};
        "fficxx"         = self.callCabal2nix "fficxx"         (fficxxSrc + "/fficxx")         {};
        "stdcxx"         = self.callPackage stdcxxNix {};
      }
      // (import ./HROOT { inherit pkgs fficxxSrc; } self super)
      // (import ./hgdal { inherit pkgs fficxxSrc; } self super);
  };

in

{
  "fficxx"         = newHaskellPackages.fficxx;
  "fficxx-runtime" = newHaskellPackages.fficxx-runtime;
  "stdcxx"         = newHaskellPackages.stdcxx
  "HROOT"          = newHaskellPackages.HROOT;
  "hgdal"          = newHaskellPackages.hgdal;
}

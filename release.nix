{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let

  fficxxSrc = lib.cleanSource ./fficxx;

  newHaskellPackages = haskellPackages.override {
    overrides = self: super:
         (import ./HROOT { inherit pkgs fficxxSrc; } self super)
      // (import ./hgdal { inherit pkgs fficxxSrc; } self super);
  };

in

{
  "HROOT" = newHaskellPackages.HROOT;
  "hgdal" = newHaskellPackages.hgdal;
}

{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let

  fficxxSrc = lib.cleanSource ./fficxx;

  newHaskellPackages = haskellPackages.override {
    overrides = import ./HROOT { inherit pkgs fficxxSrc; };
  };

in

{
  "HROOT" = newHaskellPackages.HROOT;
}
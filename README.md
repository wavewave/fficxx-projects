# fficxx-projects
Collection of public Haskell/C++ binding projects using fficxx

This is an umbrella repo for various public projects using fficxx. This repo has each project as git submodule and provide a unified build for them.

## Projects

### HROOT
One of the projects that successfully uses fficxx is [HROOT](http://ianwookim.org/HROOT) which is a haskell binding to the [ROOT](http://root.cern.ch) library. A haskell script called [HROOT-generate](http://github.com/wavewave/HROOT-generate) using fficxx generates HROOT packages. Once generated, each package can be directly installable as a cabal package. Currently, C++ interface is defined as a haskell data structure as one can see, for example, in the module [HROOT.Data.Core.Class](https://github.com/wavewave/HROOT-generate/blob/master/lib/HROOT/Data/Core/Class.hs).

## common convention

In each project (HROOT and hgdal currently),
`shell.nix` is for development,
```
nix-shell shell.nix
```
and `use.nix` is for using the generated binding package.
```
nix-shell use.nix
```

## all build
```
nix-build release.nix
```

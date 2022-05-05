# fficxx-projects

![Build](https://github.com/wavewave/fficxx-projects/actions/workflows/build.yml/badge.svg)

Collection of public Haskell/C++ binding projects using fficxx

This is an umbrella repo for various public projects using fficxx. This repo has each project as git submodule and provide a unified build for them.

## Prerequisites

This project uses Nix >= 2.4 using experimental [nix flakes](https://nixos.wiki/wiki/Flakes) feature.

## Build

After installing Nix >= 2.4 with flakes, each fficxx library can be built by (HROOT for example)
```
$ nix build .#HROOT
```

## Play with each project examples

nix develop shell (by `nix develop .#(project_name)`) will provide a playground shell environment with pre-installed
Haskell/C++ dependencies minimally required for building examples in each corresponding directory under `examples`.
The following is the HROOT example:
```
$ nix develop .#HROOT
$ cd examples/HROOT
$ ghc random2dApp.hs
```

## Projects

### HROOT
[ROOT](https://root.cern.ch) is a modular scientific software toolkit providing all the functionalities needed to deal with big data processing, statistical analysis, visualisation and storage. It is mainly written in C++ but integrated with other languages.

[HROOT](http://ianwookim.org/HROOT) is a haskell binding to the [ROOT](https://root.cern.ch) library. A haskell script called [HROOT-generate](http://github.com/wavewave/HROOT/blob/master/HROOT-generate) using fficxx generates HROOT packages. Once generated, each package can be directly installable as a cabal package. Currently, C++ interface is defined as a haskell data structure as one can see, for example, in the module [HROOT.Data.Core.Class](https://github.com/wavewave/HROOT/blob/master/HROOT-generate/lib/HROOT/Data/Core/Class.hs).

### hgdal
[GDAL](https://gdal.org) is a translator library for raster and vector geospatial data formats that is released under an X/MIT style Open Source License by the Open Source Geospatial Foundation. As a library, it presents a single raster abstract data model and single vector abstract data model to the calling application for all supported formats. It also comes with a variety of useful command line utilities for data translation and processing.

### hs-ogdf
[OGDF](https://ogdf.uos.de/) stands both for Open Graph Drawing Framework (the original name) and Open Graph algorithms and Data structures Framework.

OGDF is a self-contained C++ library for graph algorithms, in particular for (but not restricted to) automatic graph drawing. It offers sophisticated algorithms and data structures to use within your own applications or scientific projects. The library is available under the GNU General Public License.

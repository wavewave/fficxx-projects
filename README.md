# fficxx-projects
Collection of public Haskell/C++ binding projects using fficxx

This is an umbrella repo for various public projects using fficxx. This repo has each project as git submodule and provide a unified build for them.


# common convention

In each project (HROOT and hgdal currently),
`shell.nix` is for development,
```
nix-shell shell.nix
```
and `use.nix` is for using the generated binding package.
```
nix-shell use.nix
```

# all build
```
nix-build release.nix
```

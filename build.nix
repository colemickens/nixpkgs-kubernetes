let
  overlays = [ (import ./default.nix) ];
  pkgs = import (import ./nixpkgs/nixos-unstable) { inherit overlays; };
in
  pkgs.kubePkgs


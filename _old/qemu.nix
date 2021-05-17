{ removeReferencesTo, lib, fetchFromGitHub, buildGoPackage, stdenv, fetchgit, go, git, pkgs, ... }:

  lib.overrideDerivation pkgs.qemu_kvm (attrs: rec {
    name = "kata-qemu-lite";
    version = "2.11.0";
    src = fetchFromGitHub {
      owner = "kata-containers";
      repo = "qemu";
      rev = "qemu-lite-${version}";
      sha256 = "1kwdhv43qwpgi41hg6nm5v02cgs6v5rclmrrzb2fgphnv1gjpkx0";
    };
  })


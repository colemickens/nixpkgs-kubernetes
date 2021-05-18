{ stdenv, lib, fetchFromGitHub
, buildGoModule
, rustPlatform
, go, git
, qemu, cloud-hypervisor
, makeWrapper
, cargo, rustc
, llvmPackages_10
, openssl
, linuxPackages_latest
, pkg-config
, ... }:

let
  metadata = import ./metadata.nix;
in stdenv.mkDerivation rec {
  pname = "kata-runtime-internal";
  version = metadata.rev;

  # https://github.com/NixOS/nixpkgs/issues/25959
  hardeningDisable = [ "fortify" ];
  
  src = fetchFromGitHub {
    owner = "kata-containers";
    repo = "kata-containers";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };
  sourceRoot = "source/src/runtime";

  nativeBuildInputs = [
    go
  ];

  preBuild = ''
    HOME=$TMPDIR
    GOPATH=$TMPDIR/gopath
  '';

  # TODO: need to build kata-agent into kata-img

  makeFlags = [
    #"PKGDATADIR=${placeholder "out"}/share"
    "PREFIX=${placeholder "out"}"

    "DEFAULT_HYPERVISOR=qemu"
    #"DEFAULT_HYPERVISOR=cloud-hypervisor"
    "HYPERVISORS=qemu,cloud-hypervisor"
  
    "QEMUPATH=${qemu}/bin/qemu-system-x86_64"
    "CLHPATH=${cloud-hypervisor}/bin/cloud-hypervisor"
    "FCPATH=/disabled"
    "ACRNPATH=/disabled"
  ];
}


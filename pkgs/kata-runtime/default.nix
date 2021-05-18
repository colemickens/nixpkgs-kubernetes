{ stdenv, lib, fetchFromGitHub
, buildGoModule
, rustPlatform
, go, git
, qemu, cloud-hypervisor
, makeWrapper
, cargo, rustc
, llvmPackages_10
, openssl
, linuxPackages_5_11
, pkg-config
, kata-initrd
, ... }:

let
  metadata = import ./metadata.nix;
  imgKernel = linuxPackages_5_11.kernel;
  kataRootInitrd = kata-initrd;
in stdenv.mkDerivation rec {
  pname = "kata-runtime";
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

  postInstall = ''
    mkdir -p $out/share/kata-containers
    kernelDest="$out/share/kata-containers/bzImage"
    initrdDest="$out/share/kata-containers/initrd.gz"
    ln -s "${imgKernel}/bzImage" "$kernelDest"
    ln -s "${kataRootInitrd}/initrd" "$initrdDest"
    #cp "${imgKernel}/bzImage" "$kernelDest"
    #cp "${kataRootInitrd}/initrd" "$initrdDest"

    sed -i "s|kernel =.*|kernel = \"$kernelDest\"|g" \
      "$out/share/defaults/kata-containers/configuration.toml"

    sed -i "s|image =.*|initrd = \"$initrdDest\"|g" \
      "$out/share/defaults/kata-containers/configuration.toml"

    rm $out/share/defaults/kata-containers/configuration-*.toml

    mkdir -p $out/libexec/kata-qemu
    ln -s \
      "${qemu}/libexec/virtiofsd" \
      "$out/libexec/kata-qemu/virtiofsd"
  '';

  meta = {
    description = "todo";
    homepage = "https://github.com/kata-containers/kata-containers";
    license = lib.licenses.asl20; # TODO
    maintainers = with lib.maintainers; [ colemickens ]; # TODO
    platforms = lib.platforms.unix; # TODO linux only
  };
}


{ stdenv, lib, fetchFromGitHub
, buildGoModule
, rustPlatform
, go, git
, cargo, rustc
, llvmPackages_10
, openssl
, pkg-config
, ... }:

let
  rev = "f6c5f7c0ef8058fbd70bf6d47e7b2698214b729c";
  sha256 = "1gqfnan9xdfn05mbf757vnwb2wh2ky2lzhln74rv2hqpy8slyi0f";
  fullSource = fetchFromGitHub {
    owner = "kata-containers";
    repo = "kata-containers";
    rev = rev;
    sha256 = sha256;
  };
in
rustPlatform.buildRustPackage rec {
  version = rev;
  name = "kata-containers-${rev}";

  # https://github.com/NixOS/nixpkgs/issues/25959
  hardeningDisable = [ "fortify" ];

  src = fullSource;
  
  # ughm what? nix/nixpkgs, come on
  sourceRoot = "src/agent";
  
  cargoSha256 = null;

  # buildPhase = ''
  #   cp -a "${fullSource}/pkg/logging" "."
  #   sed -i 's|path = "../../pkg/logging"|path = "./pkg/logging"|g' Cargo.toml
  #   cat Cargo.toml

  #   mkdir -p $out/bin
  #   ls

  #   # RUNTIME
  #   # pushd src/runtime
  #   # make \
  #   #   KERNELTYPE="compressed" \
  #   #   DEFSHAREDFS="virtio-fs" \
  #   #   DEFVIRTIOFSDAEMON=%{_libexecdir}/"virtiofsd" \
  #   #   DEFVIRTIOFSCACHESIZE=0 \
  #   #   DEFSANDBOXCGROUPONLY=true \
  #   #   SKIP_GO_VERSION_CHECK=y \
  #   #   MACHINETYPE=%{machinetype} \
  #   #   SCRIPTS_DIR=%{_bindir} \
  #   #   DESTDIR=%{buildroot} \
  #   #   PREFIX=/usr \
  #   #   DEFAULTSDIR=%{katadefaults} \
  #   #   CONFDIR=%{katadefaults} \
  #   #   FEATURE_SELINUX="yes"
  #   # cp kata-runtime $out/bin/kata-runtime
  #   # popd

  #   # AGENT
  #   pushd src/agent
  #   mkdir -p $out/kata-out
  #   make \
  #     LIBC="gnu" \
  #     DESDIR="$out/kata-out"
  #   cp kata-agent $out/bin/kata-agent
  #   popd
  # '';

  
  nativeBuildInputs = [
    pkg-config
    cargo
    rustc
    llvmPackages_10.libclang
    llvmPackages_10.clang
  ];

  buildInputs = [
    openssl
  ]
  ;

  makeFlags = [
    "LIBC=gnu"
    "DESTDIR=${placeholder "out"}"
  ];

  # buildFlags = [
  #   "build-release"
  # ];

  # LIBCLANG_PATH = "${llvmPackages_10.libclang.lib}/lib";

  # configurePhase = null;
  # buildPhase = null;
  # doCheck = true;
  # checkPhase = null;
  # installPhase = null;

  meta = {
    description = "todo";
    homepage = "https://github.com/kata-containers/kata-containers";
    license = lib.licenses.asl20; # TODO
    maintainers = with lib.maintainers; [ colemickens ]; # TODO
    platforms = lib.platforms.unix; # TODO linux only
  };
}


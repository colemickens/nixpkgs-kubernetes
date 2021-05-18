{ stdenv, lib, fetchFromGitHub
, buildGoModule
, rustPlatform
, go, git
, makeWrapper
, cargo, rustc
, llvmPackages_10
, openssl
, pkg-config
, ... }:

let metadata = import ./metadata.nix; in
rustPlatform.buildRustPackage rec {
  version = metadata.rev;
  pname = "kata-agent";

  # https://github.com/NixOS/nixpkgs/issues/25959
  hardeningDisable = [ "fortify" ];

  src = fetchFromGitHub {
    owner = "kata-containers";
    repo = "kata-containers";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };
  sourceRoot = "source/src/agent";
 
  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    cargo
    rustc
    llvmPackages_10.libclang
    llvmPackages_10.clang
  ];

  configurePhase = ''
    make src/version.rs
  '';

  buildPhase = null;
  # doCheck = true;
  # TODO:
  #   failures:
  #    netlink::tests::list_routes
  #    rpc::tests::test_load_kernel_module
  doCheck = false;
  checkPhase = null;
  installPhase = null;

  meta = {
    description = "todo";
    homepage = "https://github.com/kata-containers/kata-containers";
    license = lib.licenses.asl20; # TODO
    maintainers = with lib.maintainers; [ colemickens ]; # TODO
    platforms = lib.platforms.unix; # TODO linux only
  };
}


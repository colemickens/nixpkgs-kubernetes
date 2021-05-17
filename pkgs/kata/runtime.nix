{ stdenv, lib, fetchFromGitHub, buildGoModule, go, git, ... }:

 buildGoModule rec {
  version = "f6c5f7c0ef8058fbd70bf6d47e7b2698214b729c";
  name = "kata-runtime-${version}";

  # https://github.com/NixOS/nixpkgs/issues/25959
  hardeningDisable = [ "fortify" ];

  src = "${fetchFromGitHub {
    owner = "kata-containers";
    repo = "kata-containers";
    rev = "${version}";
    sha256 = "1gqfnan9xdfn05mbf757vnwb2wh2ky2lzhln74rv2hqpy8slyi0f";
  }}/src/runtime";

  # postPatch = ''
  #   cp cli/config-generated.go{.in,}
  #   cp pkg/katautils/config-settings.go{.in,}
  # '';
  preBuild = ''
    go generate -x ./cli
    go generate -x ./pkg/katautils
  '';
  vendorSha256 = null;

  meta = {
    description = "todo";
    homepage = "https://github.com/kata-containers/kata-containers";
    license = lib.licenses.asl20; # TODO
    maintainers = with lib.maintainers; [ colemickens ]; # TODO
    platforms = lib.platforms.unix; # TODO linux only
  };
}


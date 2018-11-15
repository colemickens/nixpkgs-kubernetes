{ removeReferencesTo, lib, fetchFromGitHub, buildGoPackage, stdenv, fetchgit, go, git, ... }:

stdenv.mkDerivation rec {
  version = "1.3.0";
  name = "kata-images-bin-${version}";

  # https://github.com/NixOS/nixpkgs/issues/25959
  hardeningDisable = [ "fortify" ];

  src = builtins.fetchurl {
    url = "https://github.com/kata-containers/runtime/releases/download/${version}/kata-static-${version}-x86_64.tar.xz";
    sha256 = "1npdgm9wpb0l37s7m0dpiq9rh1k1zlw95q7z07l0np4289d6b85i";
  };

  installPhase = ''
    mkdir -p $out/share/
    mv kata/share/kata-containers $out/share/kata-containers
  '';

  meta = {
    description = "todo";
    homepage = https://github.com/kata-containers/images;
    license = lib.licenses.asl20; # TODO
    maintainers = with lib.maintainers; [ colemickens ]; # TODO
    platforms = lib.platforms.unix; # TODO linux only
  };
}


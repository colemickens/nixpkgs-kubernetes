{ removeReferencesTo, lib, fetchFromGitHub, buildGoPackage, stdenv, fetchgit, go, git, ... }:

stdenv.mkDerivation rec {
  version = "1.2.1";
  name = "kata-images-bin-${version}";

  # https://github.com/NixOS/nixpkgs/issues/25959
  hardeningDisable = [ "fortify" ];

  src = builtins.fetchurl {
    url = "https://github.com/kata-containers/runtime/releases/download/${version}/kata-static-${version}-x86_64.tar.xz";
    sha256 = "1z4cb68ng8j6mcd0lag6c3fbsxzzfsg5338qb4g730698kfayck5";
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


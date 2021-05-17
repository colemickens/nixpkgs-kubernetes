{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

let
  metadata = import ./metadata.nix;
in
buildGoPackage rec {
  name = "kube-router-${version}";
  version = metadata.rev;
  rev = version;

  goPackagePath = "github.com/cloudnativelabs/kube-router";

  src = fetchFromGitHub {
    inherit rev;
    owner = "cloudnativelabs";
    repo = "kube-router";
    sha256 = metadata.sha256;
  };

  meta = {
    homepage = "https://www.kube-router.io/";
    description = "Kube-router, a turnkey solution for Kubernetes networking.";
    license = lib.licenses.asl20;
  };
}


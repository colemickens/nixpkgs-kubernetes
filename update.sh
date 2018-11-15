#!/usr/bin/env bash
set -euo pipefail
set -x

cachixremote="nixpkgs-kubernetes"

# keep track of what we build and only upload at the end
pkgentries=()

function update() {
  attr="${1}"
  owner="${2}"
  repo="${3}"
  ref="${4}"

  rev=""
  url="https://api.github.com/repos/${owner}/${repo}/commits?sha=${ref}"
  rev="$(git ls-remote "https://github.com/${owner}/${repo}" "${ref}" | cut -d '	' -f1)"
  [[ -f "./${attr}/metadata.nix" ]] && oldrev="$(nix eval -f "./${attr}/metadata.nix" rev --raw)"
  if [[ "${oldrev:-}" != "${rev}" ]]; then
    revdata="$(curl -L --fail "https://api.github.com/repos/${owner}/${repo}/commits/${rev}")"
    revdate="$(echo "${revdata}" | jq -r ".commit.committer.date")"
    sha256="$(nix-prefetch-url --unpack "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz" 2>/dev/null)"
    printf '{\n  rev = "%s";\n  sha256 = "%s";\n  revdate = "%s";\n}\n' \
      "${rev}" "${sha256}" "${revdate}" > "./${attr}/metadata.nix"
    echo "${attr}" was updated to "${rev}" "${revdate}"
  fi

  commitdate="$(nix eval -f "./${attr}/metadata.nix" revdate --raw)"
  d="$(date '+%Y-%m-%d %H:%M' --date="${commitdate}")"
  txt="| ${attr} | [${d}](https://github.com/${owner}/${repo}/commits/${rev}) |"
  pkgentries=("${pkgentries[@]}" "${txt}")
}

update "nixpkgs/nixos-unstable" "nixos" "nixpkgs-channels" "nixos-unstable"
update "pkgs/containerd" "containerd" "containerd" "master"
update "pkgs/runc" "opencontainers" "runc" "master"
update "pkgs/kube-router" "cloudnativelabs" "kube-router" "master"
# TODO: update how this is handled:
#update "pkgs/kata" "kata-containers" "kata-runtime" "master"

# update README.md
set +x
replace="$(printf "<!--pkgs-->")"
replace="$(printf "%s\n| Attribute Name | Last Upstream Commit Time |" "${replace}")"
replace="$(printf "%s\n| -------------- | ------------------------- |" "${replace}")"
for p in "${pkgentries[@]}"; do
  replace="$(printf "%s\n%s\n" "${replace}" "${p}")"
done
replace="$(printf "%s\n<!--pkgs-->" "${replace}")"
set -x

rg --multiline '(?s)(.*)<!--pkgs-->(.*)<!--pkgs-->(.*)' "README.md" \
  --replace "\$1${replace}\$3" \
    > README2.md; mv README2.md README.md

rg --multiline '(?s)(.*)<!--update-->(.*)<!--update-->(.*)' "README.md" \
  --replace "\$1<!--update-->$(date '+%Y-%m-%d %H:%M')<!--update-->\$3" \
    > README2.md; mv README2.md README.md

# build all and push to cachix
nix-build --no-out-link --keep-going build.nix | cachix push "${cachixremote}"


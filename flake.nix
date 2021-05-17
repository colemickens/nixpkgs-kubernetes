{
  description = "nixpkgs-kata-containers";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = genAttrs supportedSystems;
      filterPkg_ = system: (pkg: builtins.elem "${system}" (pkg.meta.platforms or [ "x86_64-linux" "aarch64-linux" ]));
      # TODO: we probably want to skip broken?
      filterPkgs = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkg_ pkgs.system) pkgSet.${pkgs.system});
      filterHosts = pkgs: cfgs: (pkgs.lib.filterAttrs (n: v: pkgs.system == v.config.nixpkgs.system) cfgs);
      filterPkgs_ = pkgs: pkgSet: (builtins.filter (filterPkg_ pkgs.system) (builtins.attrValues pkgSet.${pkgs.system}));
      filterHosts_ = pkgs: cfgs: (builtins.filter (c: pkgs.system == c.config.nixpkgs.system) (builtins.attrValues cfgs));
      pkgsFor = pkgs: system: overlays:
        import pkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
      pkgs_ = genAttrs (builtins.attrNames inputs) (inp: genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys []));
      fullPkgs_ = genAttrs supportedSystems (sys:
        pkgsFor inputs.nixpkgs sys [ inputs.self.overlay ]);
      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [(./. + "/hosts/${hostname}/configuration.nix")];
          specialArgs = { inherit inputs; };
        };

      hydralib = import ./lib/hydralib.nix;
    in rec {
      x = builtins.trace inputs.self.sourceInfo inputs.nixpkgs.sourceInfo;
      devShell = forAllSystems (system:
        pkgs_.nixpkgs.${system}.mkShell {
          name = "nixcfg-devshell";
          nativeBuildInputs = []
          #++ ([ inputs.nix.defaultPackage.${system} ]) # TODO: drop nix input?
          ++ (with pkgs_.stable.${system}; [ cachix ])
          # ++ (with inputs.niche.packages.${system}; [ niche ])
          ++ (with pkgs_.nixpkgs.${system}; [
            nixUnstable
            #inputs.nickel.packages.${system}.build
            bash cacert curl git jq parallel mercurial
            nettools openssh ripgrep rsync
            nix-build-uncached nix-prefetch-git
            sops awsweeper packet-cli
          ]);
        }
      );

      packages = forAllSystems (system: fullPkgs_.${system}.kataPackages);
      pkgs = forAllSystems (system: fullPkgs_.${system});

      overlay = final: prev:
        let p = rec {
          kata-containers = prev.callPackage ./pkgs/kata {};
        }; in p // { kataPackages = p; };

      nixosModules = {
        kata = import ./modules/hydra-auto.nix;
      };
    };
}

/*
self: pkgs:
let
  kubePkgs = {
    runc        = pkgs.callPackage ./pkgs/runc {};
    containerd  = pkgs.callPackage ./pkgs/containerd {};
    kube-router = pkgs.callPackage ./pkgs/kube-router {};
  };
  kubeModules = {
    kix-containerd  = pkgs.callPackage ./modules/kix-containerd {};
    kix-kube-router = pkgs.callPackage ./modules/kix-kube-router {};
    kix-kubelet     = pkgs.callPackage ./modules/kix-kubelet {};
    kix-kata        = pkgs.callPackage ./modules/kix-kata {};
  };
in
  kubePkgs // { inherit kubePkgs; }
*/

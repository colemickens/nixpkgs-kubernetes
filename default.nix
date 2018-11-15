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


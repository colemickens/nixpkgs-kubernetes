{ stdenv, lib
, linuxPackages_latest
, ... }:

let
  customLinuxPackages = linuxPackages_latest.extend (lib.const (ksuper: {
    kernel = ksuper.kernel.override {
      extraConfig = ''
        FUSE_FS y
        VHOST y
        VSOCKETS y
        VHOST_VSOCK y
        VIRTIO_FS y
      '';
    };
  }));

  linuxPackages = linuxPackages_latest;
in
  #customLinuxPackages.kernel
  linuxPackages.kernel

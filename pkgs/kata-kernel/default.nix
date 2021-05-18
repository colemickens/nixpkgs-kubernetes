{ stdenv, lib
, linuxPackages_latest
, ... }:

(linuxPackages_latest.extend (lib.const (ksuper: {
  kernel = ksuper.kernel.override {
    extraConfig = ''
      FUSE_FS y
      VIRTIO_FS y
    '';
  };
}))).kernel

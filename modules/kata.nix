{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.kata-containers;

  kata-kernel = pkgs.callPackage ../pkgs/kata-kernel { };
  kata-agent = pkgs.callPackage ../pkgs/kata-agent { };
  kata-images = pkgs.callPackage ../pkgs/kata-images {
    inherit kata-agent kata-kernel;
    rootfsImage = pkgs.callPackage ../pkgs/kata-images/make-ext4-fs.nix {};
  };
  kata-initrd = kata-images.initrd;
  kata-rootfs = kata-images.image;
  kata-runtime = pkgs.callPackage ../pkgs/kata-runtime { };

  kernel = "${kata-kernel}/bzImage";
  initrd = "${kata-initrd}/initrd.gz";
  rootfs = "${kata-rootfs}";
  virtiofsd = "${pkgs.qemu}/libexec/virtiofsd";
  containerdShims = pkgs.runCommand "containerd-shims"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    declare -A bins
    bins[clh]="${pkgs.cloud-hypervisor}/bin/cloud-hypervisor"
    bins[qemu]="${pkgs.qemu}/bin/qemu-kvm"
    mkdir -p $out/bin
    mkdir -p $out/share/defaults/kata-containers
    for shim in qemu clh; do
      cfg="$out/share/defaults/kata-containers/configuration-$shim.toml"

      cp "${kata-runtime}/share/defaults/kata-containers/configuration-$shim.toml" "$cfg"

      bin="''${bins[$shim]}"

      # patch up that config file
      sed -i "s|path =.*|path = \"$bin\"|g" "$cfg"
      sed -i "s|kernel =.*|kernel = \"${kernel}\"|g" "$cfg"
      #sed -i "s|image =.*|image = \"${rootfs}\"|g" "$cfg"
      sed -i "s|image =.*|initrd = \"${initrd}\"|g" "$cfg"
      sed -i "s|virtio_fs_daemon =.*|virtio_fs_daemon = \"${virtiofsd}\"|g" "$cfg"

      #
      #
      # TODO
      #
      #
      # we should blank or fix valid_{hypervisor|virtiofs_daemon}_paths

      makeWrapper \
        "${kata-runtime}/bin/containerd-shim-kata-v2" \
        "$out/bin/containerd-shim-kata-$shim-v2" \
          --set KATA_CONF_FILE "$cfg"
    done
  '';
in
{
  options.virtualisation.kata-containers = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description =
        ''
          Install kata pkgs and enable it in containerd.
        '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.callPackage (
        { stdenv, writeScriptBin, qemu
        , containerd, ... }:
        writeScriptBin "kata-test"
          ''
            set -x
            sudo systemctl restart containerd
            sleep 2
            sudo ctr run \
              --snapshotter zfs \
              --runtime "io.containerd.kata-$1.v2" \
              docker.io/library/hello-world:latest \
              foo-$RANDOM
            
            journalctl \
              _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value containerd.service` \
              > /tmp/containerd.log

          ''
      ) {})
      (pkgs.callPackage (
        { stdenv, writeScriptBin, qemu
        , containerd, ... }:
        writeScriptBin "kata-test2" 
          ''
            set -x
            ${qemu}/bin/qemu-system-x86_64 \
              -cpu host \
              -enable-kvm \
              -m 2048m \
              -nographic \
              -kernel ${kernel} \
              -initrd ${initrd} \
              -append "init=/init console=ttyS0"
          ''
      ) {})
    ];

    virtualisation.containerd.enable = true;
    virtualisation.containerd.configFile =
      pkgs.writeText "containerd.conf" ''
        subreaper = true
        oom_score = -999

        [debug]
          level = "debug"
        [plugins]
          [plugins.cri.containerd.runtimes.kata-qemu]
            runtime_type = "io.containerd.kata-qemu.v2"
            privileged_without_host_devices = true
            pod_annotations = ["io.katacontainers.*"]
            [plugins.cri.containerd.runtimes.kata-qemu.options]
              ConfigPath = "${containerdShims}/share/defaults/kata-containers/configuration-qemu.toml"
          [plugins.cri.containerd.runtimes.kata-clh]
            runtime_type = "io.containerd.kata-clh.v2"
            privileged_without_host_devices = true
            pod_annotations = ["io.katacontainers.*"]
            [plugins.cri.containerd.runtimes.kata-clh.options]
              ConfigPath = "${containerdShims}/share/defaults/kata-containers/configuration-clh.toml"
      '';
    
    systemd.services.containerd.path = with pkgs; [
      containerdShims
      zfs
    ];
  };
}


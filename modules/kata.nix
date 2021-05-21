{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.kata-containers;

  kata-kernel = pkgs.callPackage ../pkgs/kata-kernel { };
  kata-agent = pkgs.callPackage ../pkgs/kata-agent { };
  kata-runtime = pkgs.callPackage ../pkgs/kata-runtime { };
  runtimes = {
    "qemu" = "${pkgs.qemu}/bin/qemu";
    "clh" = "${pkgs.cloud-hypervisor}/bin/cloud-hypervisor";
  };

  configDir = "${kata-runtime}/share/defaults/kata-containers";

  rootfsImage = pkgs.callPackage ../lib/make-ext4-fs.nix {};
  kernel = "${kata-kernel}/bzImage";
  stage-1 = pkgs.callPackage ./stage-1.nix {
    inherit kata-agent kata-kernel;
  };
  initrd = rootfsImage {
    storePaths = [ stage-1 ];
    volumeLabel = "initrd";
    populateImageCommands = ''
      ln -sf "${stage-1}" files/init
    '';
  };
  virtiofsd = "${qemu}/libexec/virtiofsd";
  containerdShims = pkgs.runCommand "containerd-shims"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    declare -A bins
    bins["clh"]="${runtimes.clh}"
    bins["qemu"]="${runtimes.qemu}"
    mkdir -p $out/bin
    for shim in qemu clh; do
      cfg="$out/share/defaults/kata-containers/configuration-$shim.toml"

      cp "${kata-runtime}/share/defaults/kata-containers/configuration-$shim.toml" "$cfg"

      # patch up that config file
      sed -i "s|path =.*|path = \"$bins[$shim]\"|g" "$cfg"
      sed -i "s|kernel =.*|kernel = \"${kernel}\"|g" "$cfg"
      sed -i "s|image =.*|initrd = \"${initrd}\"|g" "$cfg"
      sed -i "s|virtiofs_daemon =.*|virtiofs_daemon = \"${virtiofsd}\"|g" "$cfg"

      makeWrapper \
        "${kata-containers}/bin/containerd-shim-kata-v2" \
        "$out/bin/containerd-shim-kata-$shim-v2" \
          --set KATA_CONF_FILE "$cfg"
    done
  '';

  pointer = pkgs.writeScriptBin "kata-containerd-shims" ''
    echo "${containerdShims}"
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
    environment.systemPackages = [ pointer ];
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
              ConfigPath = "${configDir}/configuration-qemu.toml"
          [plugins.cri.containerd.runtimes.kata-clh]
            runtime_type = "io.containerd.kata-clh.v2"
            privileged_without_host_devices = true
            pod_annotations = ["io.katacontainers.*"]
            [plugins.cri.containerd.runtimes.kata-clh.options]
              ConfigPath = "${configDir}/configuration-clh.toml"
      '';
    
    systemd.services.containerd.path = with pkgs; [
      containerdShims
      zfs
    ];
  };
}


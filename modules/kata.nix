# Systemd services for kata-runtime.

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.virtualisation.kata-runtime;
  #kataImages = pkgs.kata-images;
  kataImages = pkgs.kata-images-bin;

in

{
  ###### interface

  options.virtualisation.kata-runtime = {
    enable =
      mkOption {
        type = types.bool;
        default = false;
        description =
          ''
            This option enables kata-runtime,
	    by writing the necessary runtime configuration file.
          '';
      };
  };

  ###### implementation

  config = mkIf cfg.enable {
      systemd.services."kata-ksm-throttler" = {
        description = "TODO";
	   serviceConfig = {
	     ExecStart = "${pkgs.kata-ksm-throttler}/libexec/kata-ksm-throttler/kata-ksm-throttler";
             Restart = "always";
	   };
        wantedBy = [ "multi-user.target" ]; 
      };
      systemd.services."kata-vc-throttler" = {
        description = "TODO";
	   serviceConfig = {
	     ExecStart = "${pkgs.kata-ksm-throttler}/libexec/kata-ksm-throttler/trigger/virtcontainers/vc";
             Restart = "always";
	   };
        wantedBy = [ "multi-user.target" ]; 
      };
      environment.systemPackages = [ pkgs.kata-runtime ];
      environment.etc."kata-containers/configuration.toml".text = ''
	[hypervisor.qemu]
	path = "${pkgs.qemu}/bin/qemu-system-x86_64"
	kernel = "${kataImages}/share/kata-containers/vmlinuz.container"
	initrd = "${kataImages}/share/kata-containers/kata-containers-initrd.img"
	#image = "${kataImages}/share/kata-containers/kata-containers.img"
	machine_type = "pc"

	kernel_params = ""
	firmware = ""
	machine_accelerators=""

	default_vcpus = 1
	default_maxvcpus = 0
	default_bridges = 1
	#default_memory = 2048

	disable_block_device_use = false
	block_device_driver = "virtio-scsi"
	enable_iothreads = false

	[factory]

	[proxy.kata]
	path = "${pkgs.kata-proxy}/libexec/kata-containers/kata-proxy"

	[shim.kata]
	path = "${pkgs.kata-shim}/libexec/kata-containers/kata-shim"

	[agent.kata]

	[runtime]
	internetworking_model="macvtap"
      '';
    };
}


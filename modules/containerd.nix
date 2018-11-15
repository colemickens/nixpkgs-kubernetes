# Systemd services for containerd.

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.virtualisation.containerd;
  incpkgs = [
    pkgs.containerd
    pkgs.runc
    pkgs.kata-runtime 
    pkgs.iptables
  ];

  configFile = pkgs.writeText "containerd-config.toml" ''
    root = "/var/lib/containerd"
    state = "/run/containerd"
    oom_score = 0

    [grpc]
      address = "/run/containerd/containerd.sock"
      uid = 0
      gid = 0
      max_recv_message_size = 16777216
      max_send_message_size = 16777216

    [debug]
      address = ""
      uid = 0
      gid = 0
      level = ""

    [metrics]
      address = ""
      grpc_histogram = false

    [cgroup]
      path = ""

    [plugins]
      [plugins.cgroups]
        no_prometheus = false
      [plugins.cri]
        stream_server_address = ""
        stream_server_port = "10010"
        enable_selinux = false
        # TODO: update this
        sandbox_image = "k8s.gcr.io/pause:3.1"
        stats_collect_period = 10
        systemd_cgroup = false
        enable_tls_streaming = false
        max_container_log_line_size = 16384

        [plugins.cri.containerd]
          snapshotter = "overlayfs"
          # TODO: try to undestand the different attrbitutes here and what they mean
          [plugins.cri.containerd.default_runtime]
            runtime_type = "io.containerd.runtime.v1.linux"
            runtime_engine = ""
            runtime_root = ""
          [plugins.cri.containerd.runtimes.legacy] # works
            runtime_type = "io.containerd.runtime.v1.linux"
            runtime_engine = ""
            runtime_root = ""
          [plugins.cri.containerd.runtimes.runc] # doesn't work
            runtime_type = "io.containerd.runc.v1"
            runtime_engine = ""
            runtime_root = ""
          [plugins.cri.containerd.runtimes.runc2] # doesn't work
            runtime_type = "io.containerd.runc.v1"
            runtime_engine = "${pkgs.runc}/bin/runc"
            runtime_root = ""
          [plugins.cri.containerd.runtimes.kata] # works
            runtime_type = "io.containerd.runtime.kata.v2"
            runtime_engine = "io.containerd.runtime.kata.v2"
            runtime_root = ""
        [plugins.cri.cni]
          bin_dir = "${pkgs.cni-plugins}/bin"
          conf_dir = "${config.services.kubernetes.kubelet.absoluteCniConfigDir}"
      [plugins.diff-service]
        default = ["walking"]
      [plugins.scheduler]
        pause_threshold = 0.02
        deletion_threshold = 0
        mutation_threshold = 100
        schedule_delay = "0s"
        startup_delay = "100ms"
    '';

in

{
  ###### interface

  options.virtualisation.containerd = {
    enable =
      mkOption {
        type = types.bool;
        default = false;
        description =
          ''
            This option enables containerd, a daemon that manages
            linux containers.
          '';
      };
  };

  ###### implementation

  config = mkIf cfg.enable {
      systemd.packages = [ pkgs.containerd ];
      environment.systemPackages = incpkgs;

      systemd.services.containerd = {
        after = [ "network-online.target" "network.target" ];
        wants = [ "network-online.target" "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = [ "" "${pkgs.containerd}/bin/containerd --config=${configFile}" ];
        };
        path = incpkgs;
      };

      # TODO: assert that cri-o is not running as well
      environment.etc."crictl.yaml".text = ''
        runtime-endpoint: unix:///run/containerd/containerd.sock
        image-endpoint: unix:///run/containerd/containerd.sock
        timeout: 10
        debug: true
      '';

      systemd.sockets.containerd = {
        description = "Containerd Socket for the API";
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = "/run/containerd/containerd.sock";
          SocketMode = "0660";
          SocketUser = "root";
          SocketGroup = "root";
        };
      };

    };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.kube-router;

  # CNI-config file name is hardcoded in kube-router source code
  cniConfigFileName = "10-kuberouter.conf";
  cniFile = pkgs.writeText "cni.cfg" (builtins.toJSON cfg.cniConfig);

  preStart = with pkgs; ''
    mkdir -p ${cfg.mutableConfigPath}
    cp ${cniFile} ${cfg.mutableConfigPath}/${cniConfigFileName}
    cp "${iproute}/etc/iproute2/rt_tables" ${cfg.mutableConfigPath}/rt_tables
  '';

  start = ''
    ${pkgs.kube-router}/bin/kube-router \
    ${optionalString (cfg.kubeConfig != null) "--kubeconfig " + cfg.kubeConfig} \
    --hostname-override=${cfg.hostName} \
    --run-router=${boolToString cfg.enableRouter} \
    --run-firewall=${boolToString cfg.enableFirewall} \
    --run-service-proxy=${boolToString cfg.enableServiceProxy} \
    --advertise-cluster-ip=${boolToString cfg.advertiseServiceClusterIP} \
    --advertise-external-ip=${boolToString cfg.advertiseServiceExternalIP} \
    --enable-overlay=${boolToString cfg.enablePodOverlayNetwork} \
    --hairpin-mode=${boolToString cfg.enableHairpinMode} \
    --enable-pod-egress=${boolToString cfg.enablePodSNAT} \
    ${optionalString (length cfg.peerRouters > 0) ''
      --peer-router-asns=${concatMapStringsSep "," (router: toString router.asn) cfg.peerRouters} \
      --peer-router-ips=${concatMapStringsSep "," (router: router.ip) cfg.peerRouters} \
      --peer-router-passwords=${concatMapStringsSep "," (router: router.password) cfg.peerRouters} \
    ''} \
    --cluster-asn=${toString cfg.clusterASN} \
    --nodes-full-mesh=${boolToString cfg.nodesFullMesh} \
    --metrics-port=${toString cfg.metricsPort} \
    --metrics-path="${cfg.metricsPath}" \
    --iptables-sync-period="${cfg.iptablesSyncPeriod}" \
    --ipvs-sync-period="${cfg.ipvsSyncPeriod}" \
    --routes-sync-period="${cfg.routesSyncPeriod}" \
    --v="${toString cfg.verbosity}" \
    ${cfg.extraOpts}
  '';

  postStop = "rm -fr ${cfg.mutableConfigPath}";

in
{
  options = {

    services.kube-router = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the kube-router module.";
      };

      hostName = mkOption {
        type = types.str;
        default = config.networking.hostName;
        description = "Override hostname used by kube-router.";
      };

      kubeConfig = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/path/to/kubeconfig.json";
        description = "Path to kubeconfig file";
      };

      enableRouter = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the kube-router router component.";
      };

      enableFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the kube-router firewall component.";
      };

      enableServiceProxy = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the kube-router service-proxy component.";
      };

      advertiseServiceClusterIP = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to advertise service clusterIP's to BGP peers.";
      };

      advertiseServiceExternalIP = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to advertise service externalIP's to BGP peers.";
      };

      enablePodOverlayNetwork = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable IPIP tunneling overlay network for pod-to-pod traffic.";
      };

      enableHairpinMode = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable clusterwide pod->service hairpinning.";
      };

      enablePodSNAT = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SNAT'ing of pod egress traffic.";
      };

      peerRouters = mkOption {

        type = types.listOf (types.submodule {

          options = {

            asn = mkOption {
              type = types.int;
              example = 32697;
              description = "ASN of the BGP peer-router.";
            };

            ip = mkOption {
              type = types.str;
              example = "10.0.0.1";
              description = "IP-address of the BGP peer-router.";
            };

            password = mkOption {
              type = types.str;
              default = "";
              description = "Password for the BGP peer-router.";
            };

          };
        });

        default = [];
        description = "List of external routers to BGP-peer with.";
      };

      cniConfig = mkOption {
        type = types.nullOr types.attrs;
        default = null;
        example = {
                    name = "k8snet";
                    type = "bridge";
                    bridge = "kube-bridge";
                    isDefaultGateway = true;
                    ipam = {
                     type = "host-local";
                    };
                  };
        description = "CNI config to be referenced by kube-router.";
      };

      mutableConfigPath = mkOption {
        type = types.path;
        default = "/run/kube-router";
        description = "Path for mutable CNI and RT_TABLES config.";
      };

      clusterASN = mkOption {
        type = types.int;
        default = 64512;
        description = "ASN number under which cluster nodes will run iBGP.";
      };

      nodesFullMesh = mkOption {
        type = types.bool;
        default = true;
        description = "Whether each node in the cluster will setup BGP peering with rest of the nodes.";
      };

      metricsPort = mkOption {
        type = types.int;
        default = 8080;
        description = "Prometheus metrics port to use.";
      };

      metricsPath = mkOption {
        type = types.str;
        default = "/metrics";
        description = "Path to serve Prometheus metrics on.";
      };

      iptablesSyncPeriod = mkOption {
        type = types.str;
        default = "1m0s";
        description = "The delay between iptables rule synchronizations (e.g. '5s', '1m'). Must be greater than 0.";
      };

      ipvsSyncPeriod = mkOption {
        type = types.str;
        default = "1m0s";
        description = "The delay between ipvs config synchronizations (e.g. '5s', '1m', '2h22m'). Must be greater than 0.";
      };

      routesSyncPeriod = mkOption {
        type = types.str;
        default = "1m0s";
        description = "The delay between route updates and advertisements (e.g. '5s', '1m', '2h22m'). Must be greater than 0.";
      };

      verbosity = mkOption {
        type = types.int;
        default = 0;
        description = "Log verbosity level for kube-router. The higher the number, the more chatty.";
      };

      extraOpts = mkOption {
        type = types.str;
        default = "";
        description = "Literal extra cmd line options to add to the start script of kube-router.";
      };
    };
  };

  config = mkIf cfg.enable {

    environment.etc = {

      "cni/net.d/${cniConfigFileName}" = mkIf (cfg.cniConfig != null) {
        source = concatStringsSep "/" [cfg.mutableConfigPath cniConfigFileName];
      };

      "iproute2/rt_tables".source = concatStringsSep "/" [cfg.mutableConfigPath "rt_tables"];
    };

    systemd.services.kube-router = with pkgs; {
      path = [ iproute ipset iptables kmod conntrack_tools ];
      description = "Kube Router";
      wantedBy = ["multi-user.target"];
      after = ["kubernetes.target"];
      requires = ["kubernetes.target"];
      inherit preStart;
      inherit postStop;
      script = start;
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}


{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.kata-containers;
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
    nixpkgs.overlays = [
      (import ../default.nix).overlay
    ];
    virtualisation.containerd.enable = true;
    virtualisation.containerd.configFile =
      pkgs.writeText "containerd.conf" ''
        subreaper = true
        oom_score = -999

        [debug]
          level = "debug"
        [plugins]
          [plugins.cri]
              [plugins.cri.containerd]
              default_runtime_name = "kata"

              [plugins.cri.containerd.runtimes.kata]
              runtime_type = "io.containerd.kata.v2"
      '';
    
    systemd.services.containerd.path = with pkgs; [
      kata-runtime
    ];
  };
}


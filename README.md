# nixpkgs-kubernetes

## STATUS: WIP

## Overview

Contains some packages and modules for running containerd+kata on NixOS.

## Status

1. Add the nixos module from this flake
  to your flake/config.

2. Try this:

```
❯ sudo ctr c del foo; sudo ctr run --snapshotter native --runtime io.containerd.kata.v2 docker.io/library/hello-world:latest foo

ctr: failed to create shim: Failed to check if grpc server is working: rpc error: code = DeadlineExceeded desc = timed out connecting to vsock 262325044:1024: unknown
```

3. Get this failed containerd debug journal log:

```
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.552584864-07:00" level=debug msg="received signal" signal=terminated
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.552901047-07:00" level=debug msg="sd notification" error="<nil>" notified=true state="STOPPING=1"
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.553590383-07:00" level=info msg="Stop CRI service"
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.555548996-07:00" level=debug msg="cni watcher channel is closed"
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.555609032-07:00" level=info msg="Stop CRI service"
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.556659618-07:00" level=info msg="Event monitor stopped"
May 17 19:43:06 raisin containerd[1595833]: time="2021-05-17T19:43:06.556775876-07:00" level=info msg="Stream server stopped"
May 17 19:43:06 raisin systemd[1]: containerd.service: Succeeded.
May 17 19:43:06 raisin systemd[1]: Stopped containerd - container runtime.
May 17 19:43:06 raisin systemd[1]: /nix/store/k9n32ay4gcqnm74gh9pl9dnax0pl83b2-unit-containerd.service/containerd.service:22: Unknown key name 'StartLimitIntervalSec' in section 'Service', ignoring.
May 17 19:43:07 raisin systemd[1]: Starting containerd - container runtime...
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07-07:00" level=warning msg="deprecated version : `1`, please switch to version `2`"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.207907459-07:00" level=info msg="starting containerd" revision=v1.5.0 version=v1.5.0
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.207930531-07:00" level=debug msg="changing OOM score to -999"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.221702256-07:00" level=info msg="loading plugin \"io.containerd.content.v1.content\"..." type=io.containerd.content.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.221769114-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.aufs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222199549-07:00" level=info msg="skip loading plugin \"io.containerd.snapshotter.v1.aufs\"..." error="aufs is not supported (modprobe aufs failed: exec: \"modprobe\": executable file not found in $PATH \"\"): skip plugin" type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222241313-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.btrfs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222445959-07:00" level=info msg="skip loading plugin \"io.containerd.snapshotter.v1.btrfs\"..." error="path /var/lib/containerd/io.containerd.snapshotter.v1.btrfs (zfs) must be a btrfs filesystem to be used with the btrfs snapshotter: skip plugin" type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222467459-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.devmapper\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222771685-07:00" level=warning msg="failed to load plugin io.containerd.snapshotter.v1.devmapper" error="devmapper not configured"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222780488-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.native\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.222799418-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.overlayfs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223058147-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.zfs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223404794-07:00" level=info msg="skip loading plugin \"io.containerd.snapshotter.v1.zfs\"..." error="exec: \"zfs\": executable file not found in $PATH: \"zfs fs list -Hp -o name,origin,used,available,mountpoint,compression,type,volsize,quota,referenced,written,logicalused,usedbydataset raisintank/containerd\" => : skip plugin" type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223430098-07:00" level=info msg="loading plugin \"io.containerd.metadata.v1.bolt\"..." type=io.containerd.metadata.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223450850-07:00" level=warning msg="could not use snapshotter devmapper in metadata plugin" error="devmapper not configured"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223459205-07:00" level=info msg="metadata content store policy set" policy=shared
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223690848-07:00" level=info msg="loading plugin \"io.containerd.differ.v1.walking\"..." type=io.containerd.differ.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223813261-07:00" level=info msg="loading plugin \"io.containerd.gc.v1.scheduler\"..." type=io.containerd.gc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.223838555-07:00" level=info msg="loading plugin \"io.containerd.service.v1.introspection-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224013786-07:00" level=info msg="loading plugin \"io.containerd.service.v1.containers-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224029161-07:00" level=info msg="loading plugin \"io.containerd.service.v1.content-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224037027-07:00" level=info msg="loading plugin \"io.containerd.service.v1.diff-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224045611-07:00" level=info msg="loading plugin \"io.containerd.service.v1.images-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224053418-07:00" level=info msg="loading plugin \"io.containerd.service.v1.leases-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224061086-07:00" level=info msg="loading plugin \"io.containerd.service.v1.namespaces-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224070556-07:00" level=info msg="loading plugin \"io.containerd.service.v1.snapshots-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224079449-07:00" level=info msg="loading plugin \"io.containerd.runtime.v1.linux\"..." type=io.containerd.runtime.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224246932-07:00" level=info msg="loading plugin \"io.containerd.runtime.v2.task\"..." type=io.containerd.runtime.v2
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224285479-07:00" level=debug msg="loading tasks in namespace" namespace=default
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.224419355-07:00" level=info msg="loading plugin \"io.containerd.monitor.v1.cgroups\"..." type=io.containerd.monitor.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225051130-07:00" level=info msg="loading plugin \"io.containerd.service.v1.tasks-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225100740-07:00" level=info msg="loading plugin \"io.containerd.internal.v1.restart\"..." type=io.containerd.internal.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225446611-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.containers\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225473269-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.content\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225483077-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.diff\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225489630-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.events\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225497696-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.healthcheck\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225505473-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.images\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225512344-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.leases\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225519066-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.namespaces\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225525568-07:00" level=info msg="loading plugin \"io.containerd.internal.v1.opt\"..." type=io.containerd.internal.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225555064-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.snapshots\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225564404-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.tasks\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225574920-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.version\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225580865-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.cri\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.225916429-07:00" level=info msg="Start cri plugin with config {PluginConfig:{ContainerdConfig:{Snapshotter:overlayfs DefaultRuntimeName:kata DefaultRuntime:{Type: Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:map[] PrivilegedWithoutHostDevices:false BaseRuntimeSpec:} UntrustedWorkloadRuntime:{Type: Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:map[] PrivilegedWithoutHostDevices:false BaseRuntimeSpec:} Runtimes:map[kata:{Type:io.containerd.kata.v2 Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:map[] PrivilegedWithoutHostDevices:false BaseRuntimeSpec:}] NoPivot:false DisableSnapshotAnnotations:true DiscardUnpackedLayers:false} CniConfig:{NetworkPluginBinDir:/opt/cni/bin NetworkPluginConfDir:/etc/cni/net.d NetworkPluginMaxConfNum:1 NetworkPluginConfTemplate:} Registry:{ConfigPath: Mirrors:map[] Configs:map[] Auths:map[] Headers:map[]} ImageDecryption:{KeyModel:node} DisableTCPService:true StreamServerAddress:127.0.0.1 StreamServerPort:0 StreamIdleTimeout:4h0m0s EnableSelinux:false SelinuxCategoryRange:1024 SandboxImage:k8s.gcr.io/pause:3.5 StatsCollectPeriod:10 SystemdCgroup:false EnableTLSStreaming:false X509KeyPairStreaming:{TLSCertFile: TLSKeyFile:} MaxContainerLogLineSize:16384 DisableCgroup:false DisableApparmor:false RestrictOOMScoreAdj:false MaxConcurrentDownloads:3 DisableProcMount:false UnsetSeccompProfile: TolerateMissingHugetlbController:true DisableHugetlbController:true IgnoreImageDefinedVolumes:false NetNSMountsUnderStateDir:false} ContainerdRootDir:/var/lib/containerd ContainerdEndpoint:/run/containerd/containerd.sock RootDir:/var/lib/containerd/io.containerd.grpc.v1.cri StateDir:/run/containerd/io.containerd.grpc.v1.cri}"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.227032451-07:00" level=info msg="Connect containerd service"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.227129721-07:00" level=info msg="Get image filesystem path \"/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs\""
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.227990779-07:00" level=error msg="failed to load cni during init, please check CRI plugin status before setting up network for pods" error="cni config load failed: no network config found in /etc/cni/net.d: cni plugin not initialized: failed to load cni config"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228037074-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.introspection\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228100197-07:00" level=info msg="Start subscribing containerd event"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228192986-07:00" level=info msg="Start recovering state"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228456225-07:00" level=info msg="Start event monitor"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228482515-07:00" level=info msg="Start snapshots syncer"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228489296-07:00" level=info msg="Start cni network conf syncer"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228492702-07:00" level=info msg="Start streaming server"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228759894-07:00" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228792487-07:00" level=info msg=serving... address=/run/containerd/containerd.sock
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228819364-07:00" level=debug msg="sd notification" error="<nil>" notified=true state="READY=1"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.228831512-07:00" level=info msg="containerd successfully booted in 0.022251s"
May 17 19:43:07 raisin systemd[1]: Started containerd - container runtime.
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.247310829-07:00" level=debug msg="received signal" signal=terminated
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.247463813-07:00" level=debug msg="sd notification" error="<nil>" notified=true state="STOPPING=1"
May 17 19:43:07 raisin systemd[1]: Stopping containerd - container runtime...
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.247513305-07:00" level=info msg="Stop CRI service"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.250332890-07:00" level=debug msg="cni watcher channel is closed"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.250384971-07:00" level=info msg="Stop CRI service"
May 17 19:43:07 raisin containerd[1614406]: time="2021-05-17T19:43:07.250394799-07:00" level=info msg="Event monitor stopped"
May 17 19:43:07 raisin systemd[1]: containerd.service: Succeeded.
May 17 19:43:07 raisin systemd[1]: Stopped containerd - container runtime.
May 17 19:43:07 raisin systemd[1]: Starting containerd - container runtime...
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07-07:00" level=warning msg="deprecated version : `1`, please switch to version `2`"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.286033560-07:00" level=info msg="starting containerd" revision=v1.5.0 version=v1.5.0
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.286044743-07:00" level=debug msg="changing OOM score to -999"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.299715812-07:00" level=info msg="loading plugin \"io.containerd.content.v1.content\"..." type=io.containerd.content.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.299771866-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.aufs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.299875230-07:00" level=info msg="skip loading plugin \"io.containerd.snapshotter.v1.aufs\"..." error="aufs is not supported (modprobe aufs failed: exec: \"modprobe\": executable file not found in $PATH \"\"): skip plugin" type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.299887896-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.btrfs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.299978395-07:00" level=info msg="skip loading plugin \"io.containerd.snapshotter.v1.btrfs\"..." error="path /var/lib/containerd/io.containerd.snapshotter.v1.btrfs (zfs) must be a btrfs filesystem to be used with the btrfs snapshotter: skip plugin" type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.299987357-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.devmapper\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300002483-07:00" level=warning msg="failed to load plugin io.containerd.snapshotter.v1.devmapper" error="devmapper not configured"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300008229-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.native\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300021742-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.overlayfs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300106166-07:00" level=info msg="loading plugin \"io.containerd.snapshotter.v1.zfs\"..." type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300196604-07:00" level=info msg="skip loading plugin \"io.containerd.snapshotter.v1.zfs\"..." error="exec: \"zfs\": executable file not found in $PATH: \"zfs fs list -Hp -o name,origin,used,available,mountpoint,compression,type,volsize,quota,referenced,written,logicalused,usedbydataset raisintank/containerd\" => : skip plugin" type=io.containerd.snapshotter.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300207757-07:00" level=info msg="loading plugin \"io.containerd.metadata.v1.bolt\"..." type=io.containerd.metadata.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300215604-07:00" level=warning msg="could not use snapshotter devmapper in metadata plugin" error="devmapper not configured"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300221439-07:00" level=info msg="metadata content store policy set" policy=shared
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300275581-07:00" level=info msg="loading plugin \"io.containerd.differ.v1.walking\"..." type=io.containerd.differ.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300286246-07:00" level=info msg="loading plugin \"io.containerd.gc.v1.scheduler\"..." type=io.containerd.gc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300364018-07:00" level=info msg="loading plugin \"io.containerd.service.v1.introspection-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300396112-07:00" level=info msg="loading plugin \"io.containerd.service.v1.containers-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300405124-07:00" level=info msg="loading plugin \"io.containerd.service.v1.content-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300415690-07:00" level=info msg="loading plugin \"io.containerd.service.v1.diff-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300425279-07:00" level=info msg="loading plugin \"io.containerd.service.v1.images-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300432897-07:00" level=info msg="loading plugin \"io.containerd.service.v1.leases-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300440127-07:00" level=info msg="loading plugin \"io.containerd.service.v1.namespaces-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300449039-07:00" level=info msg="loading plugin \"io.containerd.service.v1.snapshots-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300456030-07:00" level=info msg="loading plugin \"io.containerd.runtime.v1.linux\"..." type=io.containerd.runtime.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300489698-07:00" level=info msg="loading plugin \"io.containerd.runtime.v2.task\"..." type=io.containerd.runtime.v2
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300514802-07:00" level=debug msg="loading tasks in namespace" namespace=default
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300560778-07:00" level=info msg="loading plugin \"io.containerd.monitor.v1.cgroups\"..." type=io.containerd.monitor.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300730850-07:00" level=info msg="loading plugin \"io.containerd.service.v1.tasks-service\"..." type=io.containerd.service.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300744503-07:00" level=info msg="loading plugin \"io.containerd.internal.v1.restart\"..." type=io.containerd.internal.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300771170-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.containers\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300780103-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.content\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300789513-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.diff\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300796006-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.events\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300802588-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.healthcheck\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300811142-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.images\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300817594-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.leases\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300825909-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.namespaces\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300832024-07:00" level=info msg="loading plugin \"io.containerd.internal.v1.opt\"..." type=io.containerd.internal.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300855992-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.snapshots\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300863710-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.tasks\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300871228-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.version\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.300878089-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.cri\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.301840480-07:00" level=info msg="Start cri plugin with config {PluginConfig:{ContainerdConfig:{Snapshotter:overlayfs DefaultRuntimeName:kata DefaultRuntime:{Type: Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:map[] PrivilegedWithoutHostDevices:false BaseRuntimeSpec:} UntrustedWorkloadRuntime:{Type: Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:map[] PrivilegedWithoutHostDevices:false BaseRuntimeSpec:} Runtimes:map[kata:{Type:io.containerd.kata.v2 Engine: PodAnnotations:[] ContainerAnnotations:[] Root: Options:map[] PrivilegedWithoutHostDevices:false BaseRuntimeSpec:}] NoPivot:false DisableSnapshotAnnotations:true DiscardUnpackedLayers:false} CniConfig:{NetworkPluginBinDir:/opt/cni/bin NetworkPluginConfDir:/etc/cni/net.d NetworkPluginMaxConfNum:1 NetworkPluginConfTemplate:} Registry:{ConfigPath: Mirrors:map[] Configs:map[] Auths:map[] Headers:map[]} ImageDecryption:{KeyModel:node} DisableTCPService:true StreamServerAddress:127.0.0.1 StreamServerPort:0 StreamIdleTimeout:4h0m0s EnableSelinux:false SelinuxCategoryRange:1024 SandboxImage:k8s.gcr.io/pause:3.5 StatsCollectPeriod:10 SystemdCgroup:false EnableTLSStreaming:false X509KeyPairStreaming:{TLSCertFile: TLSKeyFile:} MaxContainerLogLineSize:16384 DisableCgroup:false DisableApparmor:false RestrictOOMScoreAdj:false MaxConcurrentDownloads:3 DisableProcMount:false UnsetSeccompProfile: TolerateMissingHugetlbController:true DisableHugetlbController:true IgnoreImageDefinedVolumes:false NetNSMountsUnderStateDir:false} ContainerdRootDir:/var/lib/containerd ContainerdEndpoint:/run/containerd/containerd.sock RootDir:/var/lib/containerd/io.containerd.grpc.v1.cri StateDir:/run/containerd/io.containerd.grpc.v1.cri}"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.301898355-07:00" level=info msg="Connect containerd service"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.301957974-07:00" level=info msg="Get image filesystem path \"/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs\""
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302288072-07:00" level=error msg="failed to load cni during init, please check CRI plugin status before setting up network for pods" error="cni config load failed: no network config found in /etc/cni/net.d: cni plugin not initialized: failed to load cni config"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302350857-07:00" level=info msg="loading plugin \"io.containerd.grpc.v1.introspection\"..." type=io.containerd.grpc.v1
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302414528-07:00" level=info msg="Start subscribing containerd event"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302479454-07:00" level=info msg="Start recovering state"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302558262-07:00" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302558421-07:00" level=info msg="Start event monitor"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302585905-07:00" level=info msg="Start snapshots syncer"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302590287-07:00" level=info msg=serving... address=/run/containerd/containerd.sock
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302596371-07:00" level=info msg="Start cni network conf syncer"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302659853-07:00" level=info msg="Start streaming server"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302638065-07:00" level=debug msg="sd notification" error="<nil>" notified=true state="READY=1"
May 17 19:43:07 raisin systemd[1]: Started containerd - container runtime.
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.302742574-07:00" level=info msg="containerd successfully booted in 0.017197s"
May 17 19:43:07 raisin containerd[1614424]: time="2021-05-17T19:43:07.407034985-07:00" level=debug msg="garbage collected" d=6.131814ms
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.534785422-07:00" level=debug msg="remove snapshot" key=foo
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.544728756-07:00" level=debug msg="event published" ns=default topic=/snapshot/remove type=containerd.events.SnapshotRemove
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.547038960-07:00" level=debug msg="event published" ns=default topic=/containers/delete type=containerd.events.ContainerDelete
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.561168501-07:00" level=debug msg="stat snapshot" key="sha256:f22b99068db93900abe17f7f5e09ec775c2826ecfe9db961fea68293744144bd"
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.565330012-07:00" level=debug msg="prepare snapshot" key=foo parent="sha256:f22b99068db93900abe17f7f5e09ec775c2826ecfe9db961fea68293744144bd"
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.571239236-07:00" level=debug msg="event published" ns=default topic=/snapshot/prepare type=containerd.events.SnapshotPrepare
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.575205797-07:00" level=debug msg="get snapshot mounts" key=foo
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.578486949-07:00" level=debug msg="event published" ns=default topic=/containers/create type=containerd.events.ContainerCreate
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.581259712-07:00" level=debug msg="get snapshot mounts" key=foo
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.600333779-07:00" level=debug msg="schedule snapshotter cleanup" snapshotter=native
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.602471492-07:00" level=debug msg="removed snapshot" key=default/11/foo snapshotter=native
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.602502886-07:00" level=debug msg="snapshot garbage collected" d=2.126733ms snapshotter=native
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.602525855-07:00" level=debug msg="garbage collected" d=2.059723ms
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.649092719-07:00" level=debug msg="registering ttrpc server"
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.649226319-07:00" level=debug msg="serving api on abstract socket" socket="[inherited from parent]"
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.649238418-07:00" level=info msg="starting signal loop" namespace=default path=/run/containerd/io.containerd.runtime.v2.task/default/foo pid=1614807
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.650127043-07:00" level=debug msg="converting /run/containerd/io.containerd.runtime.v2.task/default/foo/config.json" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=compatoci
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.651734009-07:00" level=info msg="loaded configuration" file=/nix/store/qz3g4vgjm43ff8lk8cii6si60xxdmzwc-kata-runtime-6b9e46ef54f39fa9a2e86945929482f8a2e7900e/share/defaults/kata-containers/configuration.toml format=TOML name=containerd-shim-v2 pid=1614807 sandbox=foo source=katautils
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.651869895-07:00" level=info msg="IOMMUPlatform is disabled by default." name=containerd-shim-v2 pid=1614807 sandbox=foo source=katautils
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.651734009-07:00" level=info msg="loaded configuration" file=/nix/store/qz3g4vgjm43ff8lk8cii6si60xxdmzwc-kata-runtime-6b9e46ef54f39fa9a2e86945929482f8a2e7900e/share/defaults/kata-containers/configuration.toml format=TOML name=containerd-shim-v2 pid=1614807 sandbox=foo source=katautils
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.651869895-07:00" level=info msg="IOMMUPlatform is disabled by default." name=containerd-shim-v2 pid=1614807 sandbox=foo source=katautils
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.652028600-07:00" level=info msg="shm-size detected: 67108864" source=virtcontainers subsystem=oci
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.6520286-07:00" level=info msg="shm-size detected: 67108864" source=virtcontainers subsystem=oci
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.652678224-07:00" level=info msg="create netns" name=containerd-shim-v2 netns=/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36 pid=1614807 sandbox=foo source=katautils
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.652678224-07:00" level=info msg="create netns" name=containerd-shim-v2 netns=/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36 pid=1614807 sandbox=foo source=katautils
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.666856697-07:00" level=info msg="adding volume" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu volume-type=virtio-fs
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.666856697-07:00" level=info msg="adding volume" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu volume-type=virtio-fs
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.667739024-07:00" level=info msg="Endpoints found after scan" endpoints="[]" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=network
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.667948238-07:00" level=info msg="Starting VM" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=sandbox
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.667739024-07:00" level=info msg="Endpoints found after scan" endpoints="[]" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=network
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.667948238-07:00" level=info msg="Starting VM" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=sandbox
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.668587391-07:00" level=info msg="Adding extra file [0xc0000100f0]" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.668587391-07:00" level=info msg="Adding extra file [0xc0000100f0]" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.668817338-07:00" level=info msg="launching /nix/store/kqsxwk8h5kx6r74bgwnj5l4151rl93lz-qemu-6.0.0/bin/qemu-system-x86_64 with: [-name sandbox-foo -uuid ff3fdcdc-95ae-48a9-ac5a-7abe049a796b -machine pc,accel=kvm,kernel_irqchip -cpu host,pmu=off -qmp unix:/run/vc/vm/foo/qmp.sock,server=on,wait=off -m 2048M,slots=10,maxmem=14947M -device pci-bridge,bus=pci.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2 -device virtio-serial-pci,disable-modern=false,id=serial0 -device virtconsole,chardev=charconsole0,id=console0 -chardev socket,id=charconsole0,path=/run/vc/vm/foo/console.sock,server=on,wait=off -device virtio-scsi-pci,id=scsi0,disable-modern=false -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 -device vhost-vsock-pci,disable-modern=false,vhostfd=3,id=vsock-3593815595,guest-cid=3593815595 -chardev socket,id=char-11439062ecb50ff8,path=/run/vc/vm/foo/vhost-fs.sock -device vhost-user-fs-pci,chardev=char-11439062ecb50ff8,tag=kataShared -rtc base=utc,driftfix=slew,clock=host -global kvm-pit.lost_tick_policy=discard -vga none -no-user-config -nodefaults -nographic --no-reboot -daemonize -object memory-backend-file,id=dimm1,size=2048M,mem-path=/dev/shm,share=on -numa node,memdev=dimm1 -kernel /nix/store/zp76hx4bqg51vs6b586gn86s4b0b1aiw-linux-5.11.21/bzImage -initrd /nix/store/j438fxwyvzgz536ngwjcvczjhbbwg4xi-initrd-kata/initrd -append tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 quiet panic=1 nr_cpus=16 scsi_mod.scan=none -pidfile /run/vc/vm/foo/pid -smp 1,cores=1,threads=1,sockets=16,maxcpus=16]" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.668817338-07:00" level=info msg="launching /nix/store/kqsxwk8h5kx6r74bgwnj5l4151rl93lz-qemu-6.0.0/bin/qemu-system-x86_64 with: [-name sandbox-foo -uuid ff3fdcdc-95ae-48a9-ac5a-7abe049a796b -machine pc,accel=kvm,kernel_irqchip -cpu host,pmu=off -qmp unix:/run/vc/vm/foo/qmp.sock,server=on,wait=off -m 2048M,slots=10,maxmem=14947M -device pci-bridge,bus=pci.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2 -device virtio-serial-pci,disable-modern=false,id=serial0 -device virtconsole,chardev=charconsole0,id=console0 -chardev socket,id=charconsole0,path=/run/vc/vm/foo/console.sock,server=on,wait=off -device virtio-scsi-pci,id=scsi0,disable-modern=false -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 -device vhost-vsock-pci,disable-modern=false,vhostfd=3,id=vsock-3593815595,guest-cid=3593815595 -chardev socket,id=char-11439062ecb50ff8,path=/run/vc/vm/foo/vhost-fs.sock -device vhost-user-fs-pci,chardev=char-11439062ecb50ff8,tag=kataShared -rtc base=utc,driftfix=slew,clock=host -global kvm-pit.lost_tick_policy=discard -vga none -no-user-config -nodefaults -nographic --no-reboot -daemonize -object memory-backend-file,id=dimm1,size=2048M,mem-path=/dev/shm,share=on -numa node,memdev=dimm1 -kernel /nix/store/zp76hx4bqg51vs6b586gn86s4b0b1aiw-linux-5.11.21/bzImage -initrd /nix/store/j438fxwyvzgz536ngwjcvczjhbbwg4xi-initrd-kata/initrd -append tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 cryptomgr.notests net.ifnames=0 pci=lastbus=0 quiet panic=1 nr_cpus=16 scsi_mod.scan=none -pidfile /run/vc/vm/foo/pid -smp 1,cores=1,threads=1,sockets=16,maxcpus=16]" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:30 raisin virtiofsd[1614816]: virtio_session_mount: Waiting for vhost-user socket connection...
May 17 19:43:30 raisin virtiofsd[1614816]: virtio_session_mount: Received vhost-user socket connection
May 17 19:43:30 raisin virtiofsd[1614826]: virtio_loop: Entry
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.750733859-07:00" level=info msg="QMP details" name=containerd-shim-v2 pid=1614807 qmp-capabilities=oob qmp-major-version=6 qmp-micro-version=0 qmp-minor-version=0 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.750733859-07:00" level=info msg="QMP details" name=containerd-shim-v2 pid=1614807 qmp-capabilities=oob qmp-major-version=6 qmp-micro-version=0 qmp-minor-version=0 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.752417997-07:00" level=info msg="scanner return error: read unix @->/run/vc/vm/foo/qmp.sock: use of closed network connection" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.752596207-07:00" level=info msg="VM started" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=sandbox
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.752417997-07:00" level=info msg="scanner return error: read unix @->/run/vc/vm/foo/qmp.sock: use of closed network connection" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.752596207-07:00" level=info msg="VM started" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=sandbox
May 17 19:43:30 raisin containerd[1614424]: time="2021-05-17T19:43:30.752673179-07:00" level=info msg="New client" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=kata_agent url="vsock://3593815595:1024"
May 17 19:43:30 raisin kata[1614807]: time="2021-05-17T19:43:30.752673179-07:00" level=info msg="New client" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=kata_agent url="vsock://3593815595:1024"
May 17 19:43:32 raisin virtiofsd[1614826]: virtio_loop: Unexpected poll revents 11
May 17 19:43:32 raisin virtiofsd[1614826]: virtio_loop: Exit
May 17 19:43:32 raisin kata[1614807]: time="2021-05-17T19:43:32.13361413-07:00" level=info msg="virtiofsd quits" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin kata[1614807]: time="2021-05-17T19:43:32.133703546-07:00" level=info msg="Stopping Sandbox" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin containerd[1614424]: time="2021-05-17T19:43:32.133614130-07:00" level=info msg="virtiofsd quits" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin containerd[1614424]: time="2021-05-17T19:43:32.133703546-07:00" level=info msg="Stopping Sandbox" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin containerd[1614424]: time="2021-05-17T19:43:32.133841866-07:00" level=warning msg="Unable to connect to unix socket (/run/vc/vm/foo/qmp.sock): dial unix /run/vc/vm/foo/qmp.sock: connect: no such file or directory" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:32 raisin containerd[1614424]: time="2021-05-17T19:43:32.133901131-07:00" level=error msg="Failed to connect to QEMU instance" error="dial unix /run/vc/vm/foo/qmp.sock: connect: no such file or directory" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin containerd[1614424]: time="2021-05-17T19:43:32.133934783-07:00" level=info msg="cleanup vm path" dir=/run/vc/vm/foo link=/run/vc/vm/foo name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin kata[1614807]: time="2021-05-17T19:43:32.133841866-07:00" level=warning msg="Unable to connect to unix socket (/run/vc/vm/foo/qmp.sock): dial unix /run/vc/vm/foo/qmp.sock: connect: no such file or directory" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qmp
May 17 19:43:32 raisin kata[1614807]: time="2021-05-17T19:43:32.133901131-07:00" level=error msg="Failed to connect to QEMU instance" error="dial unix /run/vc/vm/foo/qmp.sock: connect: no such file or directory" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:43:32 raisin kata[1614807]: time="2021-05-17T19:43:32.133934783-07:00" level=info msg="cleanup vm path" dir=/run/vc/vm/foo link=/run/vc/vm/foo name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:44:00 raisin kata[1614807]: time="2021-05-17T19:44:00.753422655-07:00" level=info msg="Stopping Sandbox" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:44:00 raisin kata[1614807]: time="2021-05-17T19:44:00.753470062-07:00" level=info msg="Already stopped" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.753422655-07:00" level=info msg="Stopping Sandbox" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.753470062-07:00" level=info msg="Already stopped" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=qemu
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.753520937-07:00" level=info msg="Network namespace \"/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36\" deleted" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=network
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.753680777-07:00" level=warning msg="sandbox cgroups path is empty" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=sandbox
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.753725886-07:00" level=info msg="cleanup agent" name=containerd-shim-v2 path=/run/kata-containers/shared/sandboxes/foo/shared pid=1614807 sandbox=foo source=virtcontainers subsystem=kata_agent
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.753876182-07:00" level=warning msg="failed to cleanup netns" error="failed to get netns /var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36: failed to Statfs \"/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36\": no such file or directory" name=containerd-shim-v2 path=/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36 pid=1614807 sandbox=foo source=katautils
May 17 19:44:00 raisin kata[1614807]: time="2021-05-17T19:44:00.753520937-07:00" level=info msg="Network namespace \"/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36\" deleted" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=network
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.755379705-07:00" level=debug msg="failed to delete task" error="rpc error: code = NotFound desc = container does not exist foo: not found" id=foo
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.757065583-07:00" level=info msg="shim disconnected" id=foo
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.757094003-07:00" level=warning msg="cleaning up after shim disconnected" id=foo namespace=default
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.757101168-07:00" level=info msg="cleaning up dead shim"
May 17 19:44:00 raisin kata[1614807]: time="2021-05-17T19:44:00.753680777-07:00" level=warning msg="sandbox cgroups path is empty" name=containerd-shim-v2 pid=1614807 sandbox=foo source=virtcontainers subsystem=sandbox
May 17 19:44:00 raisin kata[1614807]: time="2021-05-17T19:44:00.753725886-07:00" level=info msg="cleanup agent" name=containerd-shim-v2 path=/run/kata-containers/shared/sandboxes/foo/shared pid=1614807 sandbox=foo source=virtcontainers subsystem=kata_agent
May 17 19:44:00 raisin kata[1614807]: time="2021-05-17T19:44:00.753876182-07:00" level=warning msg="failed to cleanup netns" error="failed to get netns /var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36: failed to Statfs \"/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36\": no such file or directory" name=containerd-shim-v2 path=/var/run/netns/cnitest-5cddbbe6-d9b2-8de4-4d57-17d9120d4a36 pid=1614807 sandbox=foo source=katautils
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.779192615-07:00" level=error msg="failed to delete" cmd="/nix/store/qz3g4vgjm43ff8lk8cii6si60xxdmzwc-kata-runtime-6b9e46ef54f39fa9a2e86945929482f8a2e7900e/bin/containerd-shim-kata-v2 -namespace default -address /run/containerd/containerd.sock -publish-binary /nix/store/ikm4z2dmpkp8c48waq3sin9gq74m1f0z-containerd-1.5.0/bin/containerd -id foo -bundle /run/containerd/io.containerd.runtime.v2.task/default/foo delete" error="exit status 1"
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.779507888-07:00" level=warning msg="failed to clean up after shim disconnected" error="time=\"2021-05-17T19:44:00-07:00\" level=warning msg=\"failed to cleanup container\" container=foo error=\"open /run/vc/sbs/foo: no such file or directory\" name=containerd-shim-v2 pid=1614972 sandbox=foo source=containerd-kata-shim-v2\nio.containerd.kata.v2: open /run/vc/sbs/foo: no such file or directory\n: exit status 1" id=foo namespace=default
May 17 19:44:00 raisin containerd[1614424]: time="2021-05-17T19:44:00.779551088-07:00" level=error msg="copy shim log" error="read /proc/self/fd/16: file already closed"
```

## Todo

- rename, this isn't meant for kube anymore

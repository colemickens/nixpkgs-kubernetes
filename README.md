# nixpkgs-kubernetes

## STATUS: WIP

## Overview

Contains some packages and modules for running containerd+kata on NixOS.

## Status

1. Add the nixos module from this flake to your flake/config.

2. Try this:

```
# run qemu manually with the kernel+initrd+kata-agent
kata-test2

# run ctr run with qemu
kata-test qemu

# run ctr run with cloud-hypervisor
kata-test clh
```

# Status

Doesn't work.
- Kata needs to allow CLH to use initrd or we need ot fix the image creation for what it wants
- not sure why qemu+initrd isn't working
- ?

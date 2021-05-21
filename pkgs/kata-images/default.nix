{ lib
, makeModulesClosure
, makeInitrd, rootfsImage
, writeScript
, runCommandCC, nukeReferences, busybox, dhcpcd, glibc
, kata-agent
, kata-kernel
}:

let
  modules = makeModulesClosure {
    rootModules = availKernelMods ++ kernelMods;
    allowMissing = true;
    kernel = kata-kernel;
    firmware = null;
  };
  availKernelMods = [
    "ahci"
    "sata_nv"
    "sata_via"
    "sata_sis"
    "sata_uli"
    "ata_piix"
    "pata_marvell"

    # Standard SCSI stuff.
    "sd_mod"
    "sr_mod"

    # SD cards and internal eMMC drives.
    "mmc_block"

    # Support USB keyboards, in case the boot fails and we only have
    # a USB keyboard, or for LUKS passphrase prompt.
    "uhci_hcd"
    "ehci_hcd"
    "ehci_pci"
    "ohci_hcd"
    "ohci_pci"
    "xhci_hcd"
    "xhci_pci"
    "usbhid"
    "hid_generic" "hid_lenovo" "hid_apple" "hid_roccat"
    "hid_logitech_hidpp" "hid_logitech_dj" "hid_microsoft"

    "pcips2" "atkbd" "i8042"

    # x86 RTC needed by the stage 2 init script.
    "rtc_cmos"

    # Misc. x86 keyboard stuff.
    "pcips2" "atkbd" "i8042"

    # x86 RTC needed by the stage 2 init script.
    "rtc_cmos"

    "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio"
  ];
  kernelMods = [
    "dm_mod"
    "fuse"
    "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio"
    "virtio_balloon" "virtio_console" "virtio_rng" "virtio_vsock"
    "vsock" "vhost" "vhost_net" "vhost_vsock"
    "virtiofs"
  ];

  _dhcpcd = dhcpcd.override { udev = null; };
  extraUtils = runCommandCC "extra-utils"
  {
    buildInputs = [ nukeReferences ];
    allowedReferences = [ "out" ];
  } ''
    set +o pipefail
    mkdir -p $out/bin $out/lib
    ln -s $out/bin $out/sbin
    copy_bin_and_libs() {
      [ -f "$out/bin/$(basename $1)" ] && rm "$out/bin/$(basename $1)"
      cp -pd $1 $out/bin
    }
    # Copy Busybox
    for BIN in ${busybox}/{s,}bin/*; do
      copy_bin_and_libs $BIN
    done
    copy_bin_and_libs ${_dhcpcd}/bin/dhcpcd
    # Copy ld manually since it isn't detected correctly
    cp -pv ${glibc.out}/lib/ld*.so.? $out/lib
    # Copy all of the needed libraries
    find $out/bin $out/lib -type f | while read BIN; do
      echo "Copying libs for executable $BIN"
      LDD="$(ldd $BIN)" || continue
      LIBS="$(echo "$LDD" | awk '{print $3}' | sed '/^$/d')"
      for LIB in $LIBS; do
        TGT="$out/lib/$(basename $LIB)"
        if [ ! -f "$TGT" ]; then
          SRC="$(readlink -e $LIB)"
          cp -pdv "$SRC" "$TGT"
        fi
      done
    done
    # Strip binaries further than normal.
    chmod -R u+w $out
    stripDirs "lib bin" "-s"
    # Run patchelf to make the programs refer to the copied libraries.
    find $out/bin $out/lib -type f | while read i; do
      if ! test -L $i; then
        nuke-refs -e $out $i
      fi
    done
    find $out/bin -type f | while read i; do
      if ! test -L $i; then
        echo "patching $i..."
        patchelf --set-interpreter $out/lib/ld*.so.? --set-rpath $out/lib $i || true
      fi
    done
    # Make sure that the patchelf'ed binaries still work.
    echo "testing patched programs..."
    $out/bin/ash -c 'echo hello world' | grep "hello world"
    export LD_LIBRARY_PATH=$out/lib
    $out/bin/mount --help 2>&1 | grep -q "BusyBox"
  '';
  shell = "${extraUtils}/bin/ash";

  stage-1 = writeScript "stage-1" ''
    #!${shell}
    export PATH=${extraUtils}/bin/
    set -x

    mkdir -p /proc /sys /dev /etc/udev /tmp /run/ /lib/ /mnt/ /var/log /etc/plymouth /bin
    mount -t proc proc /proc
    mount -t sysfs sys /sys
    mount -t devtmpfs devtmpfs /dev
    mkdir /dev/pts /dev/shm
    mount -t devpts devpts /dev/pts
    mount -t tmpfs tmpfs /run
    mount -t tmpfs tmpfs /dev/shm
    
    ln -sv ${shell} /bin/sh
    ln -s ${modules}/lib/modules /lib/modules

    for x in ${lib.concatStringsSep " " kernelMods}; do
      #modprobe $x
    done

    sleep 1

    sysctl net.ipv6.conf.default.disable_ipv6=0
    sysctl net.ipv6.conf.all.disable_ipv6=0

    ${stage-2}
  '';

  stage-2 = writeScript "kata-agent" ''
    #!${shell}
    export PATH=${extraUtils}/bin/
    set -x
    exec ${kata-agent}/bin/kata-agent
  '';
in 
{
  initrd = makeInitrd {
    name = "initrd-kata";
    contents = [
      { object = stage-1;
        symlink = "/init"; }
    ];
  };

  image = rootfsImage {
    storePaths = [ stage-1 ];
    volumeLabel = "initrd";
    populateImageCommands = ''
      ln -sf "${stage-1}" files/init
    '';
  };
}

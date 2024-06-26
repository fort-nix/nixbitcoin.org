# Storage deployment is defined in ./deployment/2-format-storage.sh

{ config, lib, pkgs, modulesPath, ... }:

let
  hetznerDedicated = {
    nixbitcoinorg.hardware = {
      numCPUs = 12;
      memorySizeGiB = 64;
    };
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" ];
    boot.kernelModules = [ "kvm-amd" ];
    powerManagement.cpuFreqGovernor = "powersave";
    hardware.cpu.amd.updateMicrocode = true;
  };

  hetznerCloud = {
    nixbitcoinorg.hardware = {
      numCPUs = 2;
      memorySizeGiB = 2;
    };
    boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "xhci_pci" "sd_mod" "sr_mod" ];
  };

  # When a device marked with `nonessentialDevice` is unavailable,
  # booting succeeds and systemd marks the system as degraded.
  # This allows the system to boot when one device fails.
  nonessentialDevice = [
    "nofail"
    "x-systemd.device-timeout=10s"
  ];

  bindMount = srcPath: {
    device = srcPath;
    options = [ "bind" ];
    # Silence warning:
    # systemd-fstab-generator: Checking was requested for "<srcPath>", but it is not a device.
    noCheck = true;
  };
in
{
  imports = [
    hetznerDedicated
    # hetznerCloud
  ];

  boot.supportedFilesystems = [ "zfs" ];

  # TODO-EXTERNAL:
  # The filesystem definitions below can be replaced with zfs `mountpoint` attributes when
  # https://github.com/NixOS/nixpkgs/issues/62644 has been implemented
  fileSystems = {
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
    };
    "/boot1" = {
      device = "/dev/disk/by-label/boot1";
      fsType = "vfat";
      options = nonessentialDevice;
    };
    "/boot2" = {
      device = "/dev/disk/by-label/boot2";
      fsType = "vfat";
      options = nonessentialDevice;
    };
  };

  # Auto-mounting is not needed due to the manual mount settings (`fileSystems.*`)
  systemd.services.zfs-mount.enable = false;

  swapDevices = [
    { device = "/dev/disk/by-label/swap1"; options = nonessentialDevice; }
    { device = "/dev/disk/by-label/swap2"; options = nonessentialDevice; }
  ];

  boot.loader.grub = {
    enable = true;
    mirroredBoots = [
      { path = "/boot1"; devices = [ "/dev/sda" ]; }
      { path = "/boot2"; devices = [ "/dev/sdb" ]; }
    ];
  };
}

{ pkgs, lib, modulesPath, ... }:
with lib;
{
  imports = [
    ./1-installer-system.nix
    "${modulesPath}/installer/kexec/kexec-boot.nix"
  ];

  # Undo settings of `profiles/installation-device.nix` that allow
  # login with keyboard access
  services.getty.autologinUser = mkForce null;
  users.users.root.initialHashedPassword = mkForce null;
  users.users.nixos.initialHashedPassword = mkForce null;

  # Speed up build
  documentation.nixos.enable = mkOverride 0 false;
  documentation.enable = mkOverride 0 false;

  services.openssh.hostKeys = lib.mkForce [
    {
      path = "/run/keys/ssh-host-key";
      type = "ed25519";
    }
  ];
  # Allow serial device access
  boot.kernelParams = let
    # Copied from nixpkgs/nixos/lib/qemu-common.nix
    serialDevice =
      if pkgs.stdenv.hostPlatform.isx86 || pkgs.stdenv.hostPlatform.isRiscV then "ttyS0"
      else if (with pkgs.stdenv.hostPlatform; isAarch32 || isAarch64 || isPower) then "ttyAMA0"
      else throw "Unknown serial device for system '${pkgs.stdenv.hostPlatform.system}'";
  in [
    "console=${serialDevice},115200n8"
  ];
}

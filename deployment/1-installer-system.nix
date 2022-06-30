{ config, lib, pkgs, ... }:
with lib;
let
  baseSystem = pkgs.nixos ../base.nix;
in {
  # Use same the hostid as the final system so that the zfs pool
  # can be automatically imported
  networking.hostId = baseSystem.config.networking.hostId;
  boot.supportedFilesystems = [ "zfs" ];

  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    gptfdisk
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  users.users.root = let
    base = baseSystem.config.users.users.root;
  in {
    openssh.authorizedKeys.keys = base.openssh.authorizedKeys.keys;
    hashedPassword = base.hashedPassword;
  };

  services.logind.killUserProcesses = true;

  system.stateVersion = config.system.nixos.release;
}

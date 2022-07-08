# The base system without services

{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ./hardware.nix ];

  networking.hostName = "nixbitcoin";
  networking.hostId = "d1af0f9b";
  time.timeZone = "UTC";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    hostKeys = lib.mkForce [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  users.users.root = {
    # Create with:
    # gpg --decrypt ./secrets/client-side/root-password.gpg 2>/dev/null | mkpasswd -m sha-512 --stdin
    hashedPassword = "$6$Fdp45EVNdszmIRSn$5vw8Rs8u1v7v1YUT3BfVwwDnVbTsuyyvKcjzsOpLvbUxOeW14IFs./3MV1dEomv.Ao4RrCqW9qghcJvNFfb0Y0";

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjOWkBbvyTd5VhlWHecyAbsTFbQyxnXOJw+or9uQG5fbq7DlQFhFbDpD62jUzoNlsmfeLOgudyrD5A++Mk8NQLzGauBvmjql5RmfL1ZScqHPQi01sXQcEqbCRRR7O4tBynpJYktXGs7QJOIPikPBDBP2hBIxKkuHfv2nryiDcOT3DxgWbzEqvCRfHlH/D5NimPFP142gyGALbItCEBjoNKOPEOj/9t4FGEwXlX7bmggVLfIi6GakgxF78V2X1+5RIlQWbvfMrfQWSjKzqdS/vIqp7jZJziK66lqrJo+BQGNorh81Bsgy/p0SMdv8KoN3Xvrdxf/4pyADxmkyr1y5ryGabMHy2xqB3gna6XrrJThhMEbOD1xfwOZ7vKDu8YIfK1wzXnt3cwl+fHMlPicmi/Vh2qkYuBPbVxo1g5+XyCq9roatdvzsVdSX3+a1U1CeGee1q1p8Hf8oY5PrQBhv80RqI3HAbr3tdZD7HlPL9XY9arbm4XP67qrxM+P1L4eBx5N9vCkOjKs0Pp1XHwyfGGiTYFYsZCR6MG8SKZ6Q+zWR4UKTEgY0rNT2//wlnDlkaUl6OYAKJUYtxffZo5WjIpqAzq7qSi+Me0AD/M6QPRZpXjKOrlisagO9uV9/WycV/pVjryJcmlhyDlAwaTQeypyleeryxHNEwBYoVdyMz52Q==" # nixbitcoindev
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVyeXpwHsOV8RMtQwzPGhOlJ8n5/+4hGa2jc7T47CJC" # nickler
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICW0rZHTE+/gRpbPVw0Q6Wr3csEgU7P+Q8Kw6V2xxDsG" # Erik Arvstedt
    ];
  };

  # Refused connections are happening constantly on a public server and can be ignored
  networking.firewall.logRefusedConnections = false;

  environment.systemPackages = with pkgs; [
    htop
    tree
    vim
    tmux
    pv
  ];

  boot.cleanTmpDir = true;
  documentation.nixos.enable = false; # Speeds up evaluation

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  services.logind.killUserProcesses = true;

  # We never deal with multiple NICs in VPS deployments.
  # This allows us to stably address the external interface as `eth0`.
  networking.usePredictableInterfaceNames = false;

  system.stateVersion = "20.09";
}

{ config, pkgs, ... }:
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/f535d8123c4761b2ed8138f3d202ea710a334a1d/nixos-mailserver-f535d8123c4761b2ed8138f3d202ea710a334a1d.tar.gz";
      sha256 = "0csx2i8p7gbis0n5aqpm57z5f9cd8n9yabq04bg1h4mkfcf7mpl6";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.nixbitcoin.org";
    domains = [ "nixbitcoin.org" ];

    localDnsResolver = false;

    certificateScheme = 3;

    virusScanning = false;
  };
}

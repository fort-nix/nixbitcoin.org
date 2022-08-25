{ config, pkgs, ... }:
{
  mailserver = {
    enable = true;
    fqdn = "mail.nixbitcoin.org";
    domains = [ "nixbitcoin.org" ];

    localDnsResolver = false;

    certificateScheme = 3;

    virusScanning = false;
  };
}

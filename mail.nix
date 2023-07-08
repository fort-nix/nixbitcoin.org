{ config, pkgs, ... }:
{
  mailserver = {
    enable = true;
    fqdn = "mail.nixbitcoin.org";
    domains = [ "nixbitcoin.org" ];

    localDnsResolver = false;

    certificateScheme = "acme-nginx";

    virusScanning = false;
  };
}

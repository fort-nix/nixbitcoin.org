{ config, pkgs, ... }:
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/5675b122a947b40e551438df6a623efad19fd2e7/nixos-mailserver-5675b122a947b40e551438df6a623efad19fd2e7.tar.gz";
      sha256 = "1fwhb7a5v9c98nzhf3dyqf3a5ianqh7k50zizj8v5nmj3blxw4pi";
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

  # Enable TLSv1, needed for matrix-synapse https://github.com/matrix-org/synapse/issues/6211
  services.postfix.extraConfig = ''
    smtpd_tls_protocols = TLSv1.3, TLSv1.2, TLSv1.1, TLSv1, !SSLv2, !SSLv3
    smtpd_tls_mandatory_protocols = TLSv1.3, TLSv1.2, TLSv1.1, TLSv1, !SSLv2, !SSLv3
  '';
}

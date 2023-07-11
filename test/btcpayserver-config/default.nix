# Restore btcpaysever test config

{ config, pkgs, lib, ... }:

with lib;
let
  data = ./data;
  btcpayserverDataDir = config.services.btcpayserver.dataDir;
  runAs = user: "${pkgs.utillinux}/bin/runuser -u ${user} --";
  psql = "${config.services.postgresql.package}/bin/psql";
in
{
  nixbitcoin-org.website.donate = {
    btcpayserverAppId = lib.mkForce "qJ1NExmDYQLr6MoyZFypeeFgLNj";
    btcpayserverPayButtonId = lib.mkForce "9Bf5g2uHFaN21N2ub62fuNCUPrrmiyYSnT4a5iCniHCo";
  };

  systemd.services.importBtcpayserverConfig = rec {
    requires = [ "postgresql.service" ];
    after = requires;
    requiredBy = [ "btcpayserver.service" ];
    before = requiredBy;

    serviceConfig.Type = "oneshot";
    script = ''
      # Run if `btcpayserverDataDir` is empty, i.e. if btcpayserver hasn't been started yet
      if [[ ! $(ls -A "${btcpayserverDataDir}") ]]; then
        <${data}/db.sql ${runAs "postgres"} ${psql} btcpaydb
        ${runAs "btcpayserver"} ${pkgs.rsync}/bin/rsync ${data}/data-dir/* "${btcpayserverDataDir}"
      fi
    '';
  };
}

let
  nix-bitcoin = toString (import ../../nix-bitcoin-release.nix);
  pinned = import "${nix-bitcoin}/pkgs/nixpkgs-pinned.nix";
  nixpkgsUnstable = pinned.nixpkgs-unstable;
in
{ pkgs ? import nixpkgsUnstable { config = {}; overlays = []; } }:
let
  py = pkgs.python3;
  pyPkgs = import ./python-packages.nix;

  mkPkg = py.pkgs.callPackage;
  bech32 = mkPkg pyPkgs.bech32 {};
  lnurl = mkPkg pyPkgs.lnurl { inherit bech32; };

  python = py.withPackages (ps: with ps; [
    lnurl
    qrcode
  ]);
in {
  inherit python;

  mkPage = args:
    pkgs.runCommand "donate.html" {
      donate_args = builtins.toJSON (args // {
        html_template = ./donate-template.html;
      });
    } ''
      ${python}/bin/python ${./make-donation-page.py} "$donate_args" > $out
    '';
}

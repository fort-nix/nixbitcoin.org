let
  flake = builtins.getFlake (toString ../..);
  nixpkgsUnstable = flake.inputs.nixpkgs-unstable;
in
{ pkgs ? nixpkgsUnstable.legacyPackages.${builtins.currentSystem} }:
let
  py = pkgs.python3;
  pyPkgs = import ./python-packages.nix;

  lnurl = py.pkgs.callPackage pyPkgs.lnurl {};

  python = py.withPackages (ps: with ps; [
    lnurl
    qrcode
  ]);
in {
  inherit python;

  mkDonationPage = args: pkgs.runCommand "donate" {
    ARGS = builtins.toJSON (args // {
      html_template = ./site/donate-template.html;
      output_file = "index.html";
    });
  } ''
    install -m400 -D ${./site/site.css} $out/site.css
    cd $out
    ${python}/bin/python ${./make-donation-page.py}
  '';
}

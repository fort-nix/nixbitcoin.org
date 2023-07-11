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

  mkServiceArgs = args: {
    ExecStart = ''
      ${python}/bin/python ${./make-donation-page.py}
    '';
    environment.ARGS = builtins.toJSON (args // {
      html_template = ./donate-lnurl-template.html;
    });
  };
}

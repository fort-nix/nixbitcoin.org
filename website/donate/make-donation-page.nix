let
  flake = builtins.getFlake (toString ../..);
  nixpkgsUnstable = flake.inputs.nixpkgs-unstable;
in
{ pkgs ? nixpkgsUnstable.legacyPackages.${builtins.currentSystem} }:
let
  python = pkgs.python3.withPackages (ps: with ps; [
    bech32
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

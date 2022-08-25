# Setup interactive features on a flakes-based NixOS

inputs:
({ pkgs, lib, ... }: {

  environment.variables = {
    NIX_PATH = lib.mkForce "nixpkgs=${inputs.nixpkgs}:nixpkgs-unstable=${inputs.nixpkgs-unstable}";
  };

  nix.registry = let
    nixpkgsDef = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
    };
  in {
    # Shorthands for CLI usage
    n.to = nixpkgsDef // {
      inherit (inputs.nixpkgs) rev narHash;
    };
    nu.to = nixpkgsDef // {
      ref = "nixpkgs-unstable";
      inherit (inputs.nixpkgs-unstable) rev narHash;
    };
    nixpkgs.to = nixpkgsDef // {
      ref = "nixpkgs-unstable";
    };
    templates.to = {
      type = "github";
      owner = "NixOS";
      repo = "templates";
    };
  };

  # Only use the flake registry defined above and disable the global flake registry
  nix.settings.flake-registry = "/etc/nix/registry.json";

  programs.command-not-found.dbPath =
    pkgs.runCommandLocal "programs.sqlite" {} ''
      cp ${inputs.nixpkgs-channel}/programs.sqlite $out
    '';
})

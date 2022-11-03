# Setup interactive features on a flakes-based NixOS

inputs:
({ pkgs, lib, ... }: let

  # Update with
  # url=$(curl -LIs -o /tmp/out -w %{url_effective} https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz)
  # hash=$(nix hash to-sri --type sha256 "$(nix-prefetch-url --unpack "$url" 2>/dev/null)")
  # printf 'url = "%s";\nhash = "%s";\n' "$url" "$hash"
  nixpkgs-channel = pkgs.fetchzip {
    url = "https://releases.nixos.org/nixos/unstable/nixos-22.11pre423301.636051e3534/nixexprs.tar.xz";
    hash = "sha256-NBR4Uc/K5Ns1sqUJb8RY1yeUw1fYWUwSNppMU7x2zFQ=";
  };
in {

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
      cp ${nixpkgs-channel}/programs.sqlite $out
    '';
})

{
  inputs.nix-bitcoin.url = "github:erikarvstedt/nix-bitcoin/mempool-ea";
  # inputs.nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
  inputs.nixos-mailserver = {
    url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.05";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixpkgs-22_05.follows = "nixpkgs";
    inputs.utils.follows = "nix-bitcoin/flake-utils";
  };

  inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs";
  inputs.nixpkgs-unstable.follows = "nix-bitcoin/nixpkgsUnstable";

  # Used for extracting the DB for command-not-found
  inputs.nixpkgs-channel = {
    # Update with:
    # curl -LIs -o /tmp/out -w %{url_effective} https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz; echo
    url = "https://releases.nixos.org/nixos/unstable/nixos-22.11pre403102.f034b5693a2/nixexprs.tar.xz";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      configModules = [
        (import ./configuration.nix inputs)
        ./lib/deployment.nix
      ];

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = self.configModules ++ [
          (import ./lib/nixos-flakes-interactive.nix inputs)
        ];
      };

      # Useful for eval'ing system options: nix eval .#system.config.networking.hostName
      system = self.nixosConfigurations.default;

      systemDrv = self.system.config.system.build.toplevel;

      flakeInputs = nixpkgs.legacyPackages.${system}.writeText "flake-inputs"
        (builtins.concatStringsSep "\n" (builtins.attrValues inputs));
    } // (
      inputs.nix-bitcoin.inputs.flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          devEnv = import ./lib/dev-env.nix inputs pkgs;
        in
          {
            devShells.default = devEnv.makeShell {};
            # Called by ./shell.nix
            inherit (devEnv) makeShell;
          }
      )
    );
}

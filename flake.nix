{
  inputs.nix-bitcoin = {
    url = "github:erikarvstedt/nix-bitcoin/misc-12";
    inputs.extra-container.follows = "extra-container";
  };
  inputs.nix-bitcoin-mempool = {
    url = "github:erikarvstedt/nix-bitcoin-mempool";
    inputs.nix-bitcoin.follows = "nix-bitcoin";
  };
  inputs.nixos-mailserver = {
    url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.11";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixpkgs-22_11.follows = "nixpkgs";
    inputs.utils.follows = "nix-bitcoin/flake-utils";
  };
  inputs.extra-container = {
    url = "github:erikarvstedt/extra-container/container-checking";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "nix-bitcoin/flake-utils";
  };

  inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs";
  inputs.nixpkgs-unstable.follows = "nix-bitcoin/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      scenarios = import ./test/scenarios.nix self nixpkgs.lib;
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
            legacyPackages = {
              tests = let
                inherit (inputs.nix-bitcoin.legacyPackages.${system}) makeTestBasic;

                makeTest = name: config:
                  makeTestBasic {
                    inherit name;
                    config = {
                      imports = [
                        scenarios.base
                        config
                      ];
                      # Share the same pkgs instance among tests
                      nixpkgs.pkgs = pkgs.lib.mkDefault pkgs;
                    };
                  };
              in
                builtins.mapAttrs makeTest scenarios;
            };

            devShells.default = devEnv.makeShell {};
            # Called by ./shell.nix
            inherit (devEnv) makeShell;
          }
      )
    );
}

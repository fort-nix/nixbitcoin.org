{
  # TODO-EXTERNAL:
  # When subflake handling in Nix has been fixed (https://github.com/NixOS/nix/issues/6352)
  # derive all these inputs from the parent flake
  inputs.nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
  inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs";
  inputs.flake-utils.follows = "nix-bitcoin/flake-utils";

  outputs = { self, nixpkgs, flake-utils, nix-bitcoin }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        installerSystem = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./1-installer-system-kexec.nix ];
        };
      in {
        packages = {

          installerSystemVM = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ({ lib, modulesPath, ...}: {
                imports = [
                  ./1-installer-system.nix
                  (modulesPath + "/virtualisation/qemu-vm.nix")
                ];
                users.users.root.password = "a";
                services.getty.autologinUser = lib.mkForce "root";
                virtualisation.graphics = false;
                environment.etc.base-system.source = self.packages.${system}.baseSystem;
              })
            ];
          }).config.system.build.vm;

          installerSystemKexec = installerSystem.config.system.build.kexecBoot;

          installerSystem = installerSystem.config.system.build.toplevel;

          baseSystem = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ../base.nix ];
          }).config.system.build.toplevel;

          baseSystemWithBackups = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ../base.nix
              ../backup.nix
              ../lib/deployment.nix
              nix-bitcoin.nixosModules.default
              ({lib, ... }: {
                services.borgbackup.jobs.main.startAt = lib.mkForce [];
              })
            ];
          }).config.system.build.toplevel;
        };
      }) // {
        nixosConfigurations = {
          base = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ../base.nix ];
          };
        };

        lib = {
          postgresql = import ../maintenance/update-postgresql.nix self.nixosConfigurations.base;
        };
      };
}

{
  inputs.nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
  inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs";
  inputs.flake-utils.follows = "nix-bitcoin/flake-utils";

  # The installer system requires NixOS 22.05 for automatic initrd-secrets support
  # https://github.com/NixOS/nixpkgs/pull/176796
  inputs.nixpkgs-kexec.url = "github:erikarvstedt/nixpkgs/improve-netboot-initrd";

  outputs = { self, nixpkgs, nixpkgs-kexec, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        installerSystem = nixpkgs-kexec.lib.nixosSystem {
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
                  "${modulesPath}/virtualisation/qemu-vm.nix"
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
        };
      });
}

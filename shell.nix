let
  nix-bitcoin = toString (import ./nix-bitcoin-release.nix);
in
import "${nix-bitcoin}/helper/makeShell.nix" {
  configDir = ./.;
  shellVersion = "0.0.51";
  extraShellInitCmds = pkgs: let
    inherit (pkgs) lib;

    # Implement these as scripts instead of shell functions so they can be run from a
    # container shell.
    # This allows updating a running container via command 'container'.
    scripts = with pkgs; symlinkJoin {
      name = "scripts";
      paths = [
        (pkgs.writeScriptBin "run-node" ''
        scenarioOverridesFile=${toString ./scenarios.nix} \
          exec ${nix-bitcoin}/test/run-tests.sh "$@"
      '')

        # Run node in a container. (Requires root privileges.)
        (pkgs.writeScriptBin "container" ''
        exec run-node -s nixbitcoinorg-container container "$@"
      '')
      ];
    };
  in ''
    export PATH=${lib.makeBinPath [ scripts ]}:$PATH

    # Run node in a VM.
    # Hint: Run command 'q' in the VM for instant poweroff.
    vm() {
      run-node -s nixbitcoinorg-non-hardened vm "$@"
    }

    # Run node in a VM, without disabling the performance-decreasing hardened preset
    vm-hardened() {
      run-node -s nixbitcoinorg vm "$@"
    }

    # Launch the node in a container, render the website as text, shutdown node.
    # (Requires root privileges.)
    website() {
      container --run bash -c '${pkgs.lynx}/bin/lynx $ip -dump'
    }
  '';
}

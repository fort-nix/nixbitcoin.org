let
  # This is either a path to a local nix-bitcoin source or an attribute set to
  # be used as the fetchurl argument.
  nix-bitcoin-release = import ./nix-bitcoin-release.nix;

  nix-bitcoin-path =
    if builtins.isAttrs nix-bitcoin-release then nix-bitcoin-unpacked
    else nix-bitcoin-release;

  nixpkgs-path = (import "${toString nix-bitcoin-path}/pkgs/nixpkgs-pinned.nix").nixpkgs;
  pkgs = import nixpkgs-path {};
  nix-bitcoin = pkgs.callPackage nix-bitcoin-path {};

  nix-bitcoin-unpacked = (import <nixpkgs> {}).runCommand "nix-bitcoin-src" {} ''
    mkdir $out; tar xf ${builtins.fetchurl nix-bitcoin-release} -C $out
  '';

  # Implement these as scripts instead of shell functions so they can be run from a
  # container shell.
  # This allows updating a running container via command 'container'.
  scripts = with pkgs; symlinkJoin {
    name = "scripts";
    paths = [
      (pkgs.writeScriptBin "run-node" ''
        scenarioOverridesFile=${toString ./scenarios.nix} \
          exec ${toString nix-bitcoin-path}/test/run-tests.sh "$@"
      '')

      # Run node in a container. (Requires root privileges.)
      (pkgs.writeScriptBin "container" ''
        exec run-node -s nixbitcoinorg-container container "$@"
      '')
    ];
  };
in
with pkgs;

stdenv.mkDerivation rec {
  name = "nix-bitcoin-environment";

  path = lib.makeBinPath [ scripts ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs-path}:nix-bitcoin=${toString nix-bitcoin-path}:."
    export PATH="${path}''${PATH:+:}$PATH"

    fetch-release() {
      ${toString nix-bitcoin-path}/helper/fetch-release
    }

    krops-deploy() {
      # Ensure strict permissions on secrets/ directory before rsyncing it to
      # the target machine
      chmod 700 ${toString ./secrets}
      $(nix-build --no-out-link ${toString ./krops/deploy.nix})
    }

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
      container --run bash -c '${lynx}/bin/lynx $ip -dump'
    }

    # Print logo if
    # 1. stdout is a TTY, i.e. we're not piping the output
    # 2. the shell is interactive
    if [[ -t 1 && $- == *i* ]]; then
      ${figlet}/bin/figlet "nix-bitcoin"
    fi

    (mkdir -p secrets; cd secrets; env -i ${nix-bitcoin.generate-secrets})

    # Don't run this hook when another nix-shell is run inside this shell
    unset shellHook
  '';
}

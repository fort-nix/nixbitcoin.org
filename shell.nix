{ extraShellInitCmds ? (pkgs: "") }:
let
  nix-bitcoin = toString (import ./nix-bitcoin-release.nix);

  helpMessage = ''

    Commands for nixbitcoin.org
    ===========================
    container, co
      Run node in a container and start a shell for interacting with the container.
      (Requires root privileges.)

      Run scenario (defined in test/scenarios.nix)
        container website
        co website

      Run command in the container. Delete the container afterwards.
        container website --run c systemctl status nginx

      Run command on the host container while the container is running. Delete the container afterwards.
        # Show the homepage source
        container website --run bash -c 'curl $ip'

      Start and destroy container, show any failures that happened during startup
        container --test|-t
        container website -t

        When startup failed, enter a container shell for debugging
          container --test|-t --debug|-g

        Demo a failing scenario
          co fail -t

      Run scenario and anaylze boot performance
        co website --analyze|-a

    vm
      Run node in a VM.
      Hint: Run command 'q' in the VM for instant poweroff.

    vm-hardened
      Run node in a VM, without disabling the performance-decreasing hardened preset

    website
      Launch the node in a container, render the website as text, shutdown node.
      (Requires root privileges.)


    => This shell environment can be captured with direnv/lorri
  '';

  root = toString ./.;

  shell = import "${nix-bitcoin}/helper/makeShell.nix" {
    configDir = ./.;
    shellVersion = "0.0.51";
    extraShellInitCmds = pkgs: let
      inherit (pkgs) lib;

      extra-container = rec {
        src = pkgs.fetchFromGitHub {
          owner = "erikarvstedt";
          repo = "extra-container";
          # Branch `container-checking`
          rev = "374bd0c2ae55db1bf7ae940e16cfdf01ee204cfd";
          hash = "sha256-IWBORj8TT3MpnHm4jixb7ILkvChcLDdl+1lzA3o0mec=";
        };
        pkg = pkgs.callPackage src { pkgSrc = src; };
      };

      devEnv = with pkgs; symlinkJoin {
        name = "dev-env";
        paths = [
          (pkgs.writeScriptBin "run-node" ''
            scenarioOverridesFile=${toString ./test/scenarios.nix} \
              exec ${nix-bitcoin}/test/run-tests.sh "$@"
          '')
          extra-container.pkg
          # Used by test/cmds/website
          lynx
        ];
      };
    in ''
      export PATH=${devEnv}/bin:${toString ./test/cmds}:$PATH
      export root=i"${root}"

      # Prevent garbage collection of the source that extra-container is evaluated from
      # ${extra-container.src}

      ${extraShellInitCmds pkgs}
    '';
  };
in
  shell.overrideAttrs (old: {
    helpMessage = helpMessage + "\n\n" + old.helpMessage;
  })

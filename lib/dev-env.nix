inputs: pkgs:
rec {
  extra-container = rec {
    src = pkgs.fetchFromGitHub {
      owner = "erikarvstedt";
      repo = "extra-container";
      # Branch `container-checking`
      rev = "b94e5818dfc10e49bd461c2146404d96c2f7d26c";
      hash = "sha256-WUKXfFL44GQ3U9YVZxZqv685Gl/gQrf9CgOO/PAteos=";
    };
    pkg = pkgs.callPackage src { pkgSrc = src; };
  };

  devEnv = with pkgs; symlinkJoin {
    name = "dev-env";
    paths = [
      (pkgs.writeScriptBin "run-node" ''
        scenarioOverridesFile=$root/test/scenarios.nix \
          exec ${inputs.nix-bitcoin}/test/run-tests.sh "$@"
      '')
      extra-container.pkg
      # Used by test/
      curl
      jq
      lynx
      # Used for secrets encryption
      pass
    ];
  };

  makeShell = extraVars: import ./minimal-shell.nix { inherit pkgs; inherit (pkgs.stdenv) system; } {
    packages = [ devEnv ];
    vars = extraVars // {
      remoteHost = "root@nixbitcoin.org";

      shellHook = ''
        # Variable root points to the repo root
        if [[ ! $root ]]; then

          # If we're in a checkout of the nixbitcoin.org repo, use the
          # local repo as the root.
          # This allows editing the dev shell commands in ../test/cmds
          # without restarting the dev shell.
          #
          # A random rev from the master branch
          rev=71d7b948c62d7125cb4941bc60d0acea56fc7f8f
          if git cat-file -e $rev &>/dev/null; then
            export root=$(git rev-parse --show-toplevel)
          else
            # Use the flake src
            export root=${toString ./.}
          fi
        fi

        PATH=$root/cmds:$PATH
        export PASSWORD_STORE_DIR=$root/secrets

        # Set isInteractive=1 if
        # 1. stdout is a TTY, i.e. we're not piping the output
        # 2. the shell is interactive
        if [[ -t 1 && $- == *i* ]]; then isInteractive=1; else isInteractive=; fi

        if [[ $isInteractive ]]; then
          ${pkgs.figlet}/bin/figlet "nix-bitcoin"
          echo 'Enter "h" or "help" for documentation.'
        fi

        function help() { env help; }
      '';
    };
  };
}

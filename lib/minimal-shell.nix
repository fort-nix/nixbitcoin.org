{ pkgs, system }:

# A special kind of derivation that is only meant to be consumed by the
# nix-shell. This differs from the traditional `mkShell` in that:
# It does not come with traditional stdenv (i.e. coreutils).
# Its only dependency is essentially bash.
{
  # a list of packages to add to the shell environment
  packages ? [ ]
, vars ? {}
}:
derivation ({
  inherit system;

  name = "shell-env";

  # reference: https://github.com/NixOS/nix/blob/94ec9e47030c2a7280503d338f0dca7ad92811f5/src/nix-build/nix-build.cc#L494
  stdenv = pkgs.writeTextFile rec {
    name = "setup";
    executable = true;
    destination = "/${name}";
    # This is required for compatibility with nix-shell.
    # Directly setting the PATH drv attr leads to a nix-shell startup failure due to
    # missing coreutils.
    text = ''
      set -e
      export PATH='${pkgs.lib.makeBinPath packages}'

      # Required for shellHook support in nix-shell
      function runHook() {
        local hook=$1
        shift
        eval "''${!hook}" "$@"
      }
    '';
  };

  outputs = [ "out" ];

  builder = pkgs.stdenv.shell;
} // vars)

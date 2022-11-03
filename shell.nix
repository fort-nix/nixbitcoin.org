{ system ? builtins.currentSystem }:

(builtins.getFlake "git+file://${toString ./.}").makeShell.${system} {
  root = (toString ./.);
}

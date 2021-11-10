rec {
  tests = import <nix-bitcoin/test/tests.nix> {
    extraScenarios = import ./scenarios.nix;
  };
  config = test: tests.${test}.vm.nodes.machine.config;
}

# The tools `make check` needs, for CI, factory jobs and local dev: `nix develop`.
# nixpkgs (flake.lock) is the pin.
{
  description = "xdoubleu/skills gates: shellcheck, jq and make";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = eachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            bash
            gnumake
            jq
            shellcheck
          ];
        };
      });
    };
}

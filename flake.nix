{
  description = "MCP server for token-efficient large document analysis via the use of REPL state";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      forAll = f: genAttrs systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      overlays.default = final: _prev: {
        matryoshka-rlm = final.callPackage ./default.nix { };
      };

      packages = forAll (pkgs: {
        default = pkgs.callPackage ./default.nix { };
      });
    };
}

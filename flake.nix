{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, ... }@attrs:
    let
      inherit (nixpkgs) lib;

      listModules =
        dir:
        let
          files = builtins.filter (lib.strings.hasSuffix ".nix") (lib.filesystem.listFilesRecursive dir);

          attrName =
            p:
            builtins.replaceStrings [ "/" ] [ "-" ] (
              lib.strings.removeSuffix ".nix" (
                lib.strings.removeSuffix "/default.nix" (
                  lib.strings.removePrefix "${builtins.toString dir}/" (builtins.toString p)
                )
              )
            );
        in
        builtins.listToAttrs (
          builtins.map (p: {
            name = attrName p;
            value = p;
          }) files
        );
    in
    {
      homeManagerModules = listModules ./nix/home-manager-modules;
    }
    // attrs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}

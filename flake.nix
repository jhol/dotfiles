{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }@attrs: let
    inherit (nixpkgs) lib;

    listModules = dir: let
      files = builtins.filter
        (lib.strings.hasSuffix ".nix")
        (lib.filesystem.listFilesRecursive dir);

      attrName = p:
        builtins.replaceStrings ["/"] ["-"] (
          lib.strings.removeSuffix ".nix" (
            lib.strings.removeSuffix "/default.nix" (
              lib.strings.removePrefix "${builtins.toString dir}/"
                (builtins.toString p))));
    in builtins.listToAttrs (builtins.map (p: { name = attrName p; value = p; }) files);
  in {
    homeManagerModules = listModules ./nix/home-manager-modules;
  };
}

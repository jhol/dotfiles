{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

      listPackages =
        pkgs: builtins.mapAttrs (name: value: pkgs.callPackage value { }) (listModules ./nix/packages);
    in
    {
      homeManagerModules =
        (listModules ./nix/home-manager-modules)
        // {
          nixvim = attrs.nixvim.homeModules.nixvim;
        };

      nixosModules.overlay = {
        nixpkgs.overlays = [ self.overlays.default ];
      };

      overlays.default = final: prev: listPackages final;
    }
    // attrs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = listPackages pkgs;
      }
    );
}

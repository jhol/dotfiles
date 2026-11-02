{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi.url = "github:lukasl-dev/pi.nix";
    llm-agents.url = "github:numtide/llm-agents.nix";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No nixpkgs follows: Dux Shell 2.0 needs Go >= 1.27.1 and its pin supplies
    # the newer toolchain used by the niri module.
    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
    };

    dms-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
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
        pkgs:
        let
          callPackage = pkgs.lib.callPackageWith (pkgs // { flakeInputs = attrs; });
        in
        builtins.mapAttrs (name: value: callPackage value { }) (listModules ./nix/packages);

      # Modules that need this flake's own inputs are wrapped here so the
      # library is self-contained and consumers don't pass them via specialArgs.
      withInputs =
        path:
        { config, lib, pkgs, ... }@args:
        import path (args // { inputs = attrs; });
    in
    {
      homeManagerModules = (listModules ./nix/home-manager-modules) // {
        nixvim = attrs.nixvim.homeModules.nixvim;
        pi = attrs.pi.homeModules.default;
        niri = withInputs ./nix/home-manager-modules/niri.nix;
      };

      nixosModules.overlay = {
        nixpkgs.overlays = [ self.overlays.default ];
      };

      overlays.default = final: prev: listPackages final;
    }
    // attrs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = listPackages pkgs;
      }
    );
}

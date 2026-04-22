{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.ai-tools;

  skills = {
    "caveman" = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/JuliusBrussee/caveman/84cc3c14fa1e10182adaced856e003406ccd250d/skills/caveman/SKILL.md";
      hash = "sha256-+cg6KyD8OzUDr50a4c8gmMn4w9MmwgPCNrFg6+gayPA=";
    };

    "consolidate-test-suites" = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/regenrek/agent-skills/a1dce7f962b8bcb4f6215cf7fa4941c1cb50c426/skills/consolidate-test-suites/SKILL.md";
      sha256 = "1nq2rjhmj1hc3p29ymyvl6x71chbr6g91gw14i3d6pa36kbm1qx6";
    };
  };
in
{
  options.modules.jhol-dotfiles.ai-tools = {
    enable = lib.mkEnableOption "Enable AI Tools";

    opencodePackage = lib.mkOption {
      type = lib.types.package;
      description = ''
        **opencode** package to use for AI tools.
        Defaults to the version from the current nixpkgs.
      '';
      default = pkgs.opencode;
      defaultText = "pkgs.opencode";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.opencodePackage
    ];

    xdg.configFile =
      with lib.attrsets;
      mapAttrs' (name: drv: nameValuePair "opencode/skills/${name}/SKILL.md" { source = drv; }) skills;
  };
}

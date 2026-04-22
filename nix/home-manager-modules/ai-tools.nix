{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.ai-tools;

  skills =
    let
      caveman-src = pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "84cc3c14fa1e10182adaced856e003406ccd250d";
        hash = "sha256-M+NoWXxrhtbkbe/lmq7P0/KpmqOZzJjhgeUVjY+7N2k=";
      };

      agent-skills-src = pkgs.fetchFromGitHub {
        owner = "regenrek";
        repo = "agent-skills";
        rev = "a1dce7f962b8bcb4f6215cf7fa4941c1cb50c426";
        hash = "sha256-UUVTpf9QXOAo5yrdGwjyX8N1MkaAAhwWJ2wXUYJnA8M=";
      };
    in
    {
      "caveman" = "${caveman-src}/skills/caveman/SKILL.md";
      "consolidate-test-suites" = "${agent-skills-src}/skills/consolidate-test-suites/SKILL.md";
    };
in
{
  options.modules.jhol-dotfiles.ai-tools = {
    enable = lib.mkEnableOption "Enable AI Tools";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode.enable = true;

    # TODO: Install using programs.opencode.skills after 26.05 release
    xdg.configFile = lib.mapAttrs' (
      name: drv: lib.nameValuePair "opencode/skills/${name}/SKILL.md" { source = drv; }
    ) skills;
  };
}

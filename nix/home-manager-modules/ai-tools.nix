{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.ai-tools;

  caveman-skill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/JuliusBrussee/caveman/84cc3c14fa1e10182adaced856e003406ccd250d/skills/caveman/SKILL.md";
    hash = "sha256-+cg6KyD8OzUDr50a4c8gmMn4w9MmwgPCNrFg6+gayPA=";
  };
in
{
  options.modules.jhol-dotfiles.ai-tools = {
    enable = lib.mkEnableOption "Enable AI Tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      opencode
    ];

    xdg.configFile."opencode/skills/caveman/SKILL.md".source = caveman-skill;
  };
}

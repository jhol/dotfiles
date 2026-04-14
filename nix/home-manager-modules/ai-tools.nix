{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.ai-tools;
in
{
  options.modules.jhol-dotfiles.ai-tools = {
    enable = lib.mkEnableOption "Enable AI Tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      opencode
    ];
  };
}

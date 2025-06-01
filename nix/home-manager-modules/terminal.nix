{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.terminal;
in
{
  options.modules.jhol-dotfiles.terminal = {
    enable = lib.mkEnableOption "Enable terminal configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      font = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "SauceCodePro Nerd Font";
        size = 8;
      };

      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.jhol-dotfiles.all;
in
{
  options.modules.jhol-dotfiles.all = {
    enable = lib.mkEnableOption "Enable all home-manager modules";
  };

  config = lib.mkIf cfg.enable {
    modules.jhol-dotfiles = {
      git.enable = true;
      neovim.enable = true;
      shell.enable = true;
      terminal.enable = true;
      tools.enable = true;
      web-browsers.enable = true;
    };
  };
}

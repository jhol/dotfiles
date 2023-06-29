{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.tools;
in
{
  options.modules.jhol-dotfiles.tools = {
    enable = lib.mkEnableOption "Enable command-line tools installation";
  };

  config = lib.mkIf cfg.enable {
    home = {
      sessionPath = [ "$HOME/.local/bin" ];
      file.".local/bin" = {
        source = ./bin;
        recursive = true;
        executable = true;
      };
    };
  };
}
